import re
import traceback
import urllib.parse
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from typing import Tuple

import frappe
import requests
from requests.auth import HTTPBasicAuth

from erpnext_tnt.exceptions import TNTAPIDisabledError, TNTAPIError, TNTAPIUnexpectedResponseError


@dataclass
class TNTAPIResult:
	error: Exception = None
	raw_response_text: str = None
	data: dict = None


class TNTAPI:
	def __init__(self, dt, dn):
		self.tnt_settings = frappe.get_cached_doc("TNT Settings")
		self.dt = dt
		self.dn = dn

		if not self.tnt_settings.shipping_enabled:
			raise TNTAPIDisabledError

	def _build_xml_request(self, url, rendered_xml: str, use_form_data: bool = True) -> Tuple[dict, str, HTTPBasicAuth]:
		headers = {"SOAPAction": url, "Content-Type": "application/x-www-form-urlencoded"}
		auth = HTTPBasicAuth(self.tnt_settings.shipping_api_username, self.tnt_settings.get_password("shipping_api_password"))
		if use_form_data:
			encoded_xml = urllib.parse.quote(rendered_xml)
			payload = f"xml_in={encoded_xml}"
		else:
			payload = rendered_xml

		return headers, payload, auth

	def _parse_xml_response(self, xml_response):
		root = ET.fromstring(xml_response)
		response_data = {}
		for elem in root:
			response_data[elem.tag] = elem.text
		return response_data

	def _request(self, method, url, params=None, data=None, headers=None, auth=None) -> str:
		result = None
		parsed_url = urllib.parse.urlparse(url)

		def _enqueue_log():
			if not frappe.flags.in_test:
				frappe.enqueue(
					"erpnext_tnt.tnt.tnt_api.log_tnt_request",
					url=parsed_url.netloc,
					endpoint=parsed_url.path,
					request_method=method,
					params=params,
					data=data,
					res=result,
					traceback="".join(traceback.format_stack(limit=8)),
					reference_doctype=self.dt,
					reference_docname=self.dn,
				)

		try:
			result = requests.request(method, url, headers=headers, auth=auth, data=data)
		except Exception as e:
			_enqueue_log()
			raise e
		else:
			_enqueue_log()
			return result

	# def request_routing_label(self, request_data):
	# 	xml_payload = self._build_xml_request("RoutingLabelRequest", request_data)
	# 	headers = {"Content-Type": "application/xml"}
	# 	response = requests.post(self.endpoint, data=xml_payload, headers=headers)
	# 	return self._parse_xml_response(response.text)

	def request_shipping(self, rendered_xml: str) -> TNTAPIResult:
		result_data = {"access_code": None, "tnt_shipment": None}
		url = self.tnt_settings.express_connect_shipping_endpoint

		# Create the Consignment using the TNT API
		headers, payload, auth = self._build_xml_request(url, rendered_xml)
		try:
			post_response = self._request("POST", url, headers=headers, auth=auth, data=payload)
		except Exception as e:
			return TNTAPIResult(error=e)

		if not post_response:
			return TNTAPIResult(error=TNTAPIUnexpectedResponseError())

		# Check if result is string or XML, we expect a string e.g. "COMPLETE:123456"
		try:
			ET.fromstring(post_response.text)
		except ET.ParseError as e:
			pass
		else:
			return TNTAPIResult(error=TNTAPIUnexpectedResponseError())

		# Extract the Access Code Number
		pattern = r"(?<=COMPLETE:)\d+"
		match = re.search(pattern, post_response.text)
		if match:
			access_code = match.group()
			result_data["access_code"] = access_code
		else:
			raise TNTAPIUnexpectedResponseError(post_response.text)

		# Get the created Consignment using the TNT API
		command = f"GET_RESULT:{result_data['access_code']}"
		headers, payload, auth = self._build_xml_request(url, command)
		try:
			get_response = self._request("POST", url, headers=headers, auth=auth, data=payload)
		except Exception as e:
			return TNTAPIResult(error=e)

		# Check if result is string or XML, we expect XML
		try:
			root = ET.fromstring(get_response.text)
		except ET.ParseError as e:
			return TNTAPIResult(TNTAPIUnexpectedResponseError())

		# Check for errors in the response
		if root.tag in ["parse_error", "runtime_error"]:
			return TNTAPIResult(error=TNTAPIError(get_response.text))
		if root.tag == "document" and root.find("ERROR"):
			return TNTAPIResult(error=TNTAPIError(get_response.text))

		# Validate response
		if root.tag == "document" and (create_element := root.find("CREATE")) and create_element.find("SUCCESS").text == "Y" and (book_element := root.find("BOOK")):
			rate_element = root.find("RATE")

			service_element = rate_element.find("SERVICE")
			currency_element = rate_element.find("CURRENCY")
			chid_rate_element = rate_element.find("RATE")
			tnt_shipment = {
				"tnt_shipment_id": create_element.find("CONNUMBER").text,
				"tnt_service": service_element.text if service_element else None,
				"tnt_currency": currency_element.text if currency_element else None,
				"tnt_rate": chid_rate_element.text if chid_rate_element else None,
				"tnt_booking_reference": book_element.find("CONSIGNMENT").find("BOOKINGREF").text,
			}
			result_data["tnt_shipment"] = tnt_shipment
			self.result = TNTAPIResult(raw_response_text=get_response.text, data=result_data)
			return self.result
		else:
			return TNTAPIResult(error=TNTAPIError(get_response.text))

	def request_rates(self, rendered_xml: str) -> TNTAPIResult:
		result_data = {"access_code": None, "tnt_shipment": None, "rates": None}
		url = self.tnt_settings.express_connect_pricing_endpoint

		# Get the Rates using the TNT API
		headers, payload, auth = self._build_xml_request(url, rendered_xml, use_form_data=False)
		try:
			get_response = self._request("POST", url, headers=headers, auth=auth, data=payload)
		except Exception as e:
			return TNTAPIResult(error=e)

		# Check if result is string or XML, we expect XML
		try:
			root = ET.fromstring(get_response.text)
		except ET.ParseError as e:
			return TNTAPIResult(TNTAPIUnexpectedResponseError())

		# Check for errors in the response
		if root.tag in ["parse_error", "runtime_error"]:
			return TNTAPIResult(error=TNTAPIError(get_response.text))

		# Validate response
		if root.tag == "document" and root.find("priceResponse"):
			rated_services = []

			for rated_service in root.findall(".//ratedService"):
				service_dict = {}

				# Extract product info
				product = rated_service.find("product")
				if product is not None:
					service_dict["product"] = {"id": product.findtext("id"), "productDesc": product.findtext("productDesc")}

				# Extract pricing details
				service_dict["totalPrice"] = rated_service.findtext("totalPrice")
				service_dict["totalPriceExclVat"] = rated_service.findtext("totalPriceExclVat")
				service_dict["vatAmount"] = rated_service.findtext("vatAmount")

				# Extract charge elements
				charge_elements = []
				for charge in rated_service.findall("./chargeElements/chargeElement"):
					charge_dict = {
						"chargeItem": charge.findtext("chargeItem"),
						"chargeCategory": charge.findtext("chargeCategory"),
						"chargeCode": charge.findtext("chargeCode"),
						"description": charge.findtext("description"),
						"chargeValue": charge.findtext("chargeValue"),
						"vatIndicator": charge.findtext("vatIndicator"),
					}
					charge_elements.append(charge_dict)
				service_dict["chargeElements"] = charge_elements

				rated_services.append(service_dict)

			result_data["rates"] = rated_services
			self.result = TNTAPIResult(raw_response_text=get_response.text, data=result_data)
			return self.result
		else:
			return TNTAPIResult(error=TNTAPIError(get_response.text))


def log_tnt_request(
	url: str,
	endpoint: str,
	request_method: str,
	params: dict,
	data: dict,
	res: requests.Response | None = None,
	traceback: str = None,
	reference_doctype: str = None,
	reference_docname: str = None,
):
	request_log = frappe.get_doc(
		{
			"doctype": "TNT Request Log",
			"user": frappe.session.user if frappe.session.user else None,
			"url": url,
			"endpoint": endpoint,
			"method": request_method,
			"params": frappe.as_json(params) if params else None,
			"data": frappe.as_json(data) if data else None,
			"response": f"{str(res)}\n{res.text}" if res is not None else None,
			"error": frappe.get_traceback(),
			"status": "Success" if res and res.status_code in [200, 201] else "Error",
			"traceback": traceback,
			"time_elapsed": res.elapsed.total_seconds() if res is not None else None,
			"reference_doctype": reference_doctype,
			"reference_docname": reference_docname,
		}
	)

	request_log.save(ignore_permissions=True)
