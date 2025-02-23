import re
import traceback
import urllib.parse
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from typing import Tuple

import frappe
import requests

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

	def _build_xml_request(self, rendered_xml: str) -> Tuple[str, dict, str]:

		url = self.tnt_settings.express_connect_shipping_endpoint
		headers = {"SOAPAction": self.tnt_settings.express_connect_shipping_endpoint, "Content-Type": "application/x-www-form-urlencoded"}
		encoded_xml = urllib.parse.quote(rendered_xml)
		payload = f"xml_in={encoded_xml}"

		return url, headers, payload

	def _parse_xml_response(self, xml_response):
		root = ET.fromstring(xml_response)
		response_data = {}
		for elem in root:
			response_data[elem.tag] = elem.text
		return response_data

	def _request(self, method, url, params=None, data=None, headers=None) -> str:
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
			result = requests.request(method, url, headers=headers, data=data)
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

		# Create the Consignment using the TNT API
		url, headers, payload = self._build_xml_request(rendered_xml)
		try:
			post_response = self._request("POST", url, headers=headers, data=payload)
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
		url, headers, payload = self._build_xml_request(command)
		try:
			get_response = self._request("POST", url, headers=headers, data=payload)
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
		if root.tag == "document" and (create_element := root.find("CREATE")) and create_element.find("SUCCESS").text == "Y":
			rate_element = root.find("RATE")
			book_element = root.find("BOOK")
			tnt_shipment = {
				"tnt_shipment_id": create_element.find("CONREF").text,
				"tnt_service": rate_element.find("SERVICE").text,
				"tnt_currency": rate_element.find("CURRENCY").text,
				"tnt_rate": rate_element.find("RATE").text,
				"tnt_booking_reference": book_element.find("BOOKINGREF").text,
			}
			result_data["tnt_shipment"] = create_element.find("SUCCESS")
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
