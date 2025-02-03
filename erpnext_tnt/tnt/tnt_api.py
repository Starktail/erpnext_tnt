import xml.etree.ElementTree as ET

import requests


class TNTAPI:
	def __init__(self, username, password, endpoint, carrier_account):
		self.username = username
		self.password = password
		self.endpoint = endpoint
		self.carrier_account = carrier_account

	def _build_xml_request(self, root_tag, data_dict):
		root = ET.Element(root_tag)
		# Authentication block
		auth = ET.SubElement(root, "Authentication")
		ET.SubElement(auth, "Username").text = self.username
		ET.SubElement(auth, "Password").text = self.password

		# Carrier info
		ET.SubElement(root, "CarrierAccount").text = self.carrier_account

		# Request-specific data
		for key, value in data_dict.items():
			ET.SubElement(root, key).text = str(value)
		return ET.tostring(root, encoding="utf-8", method="xml")

	def _parse_xml_response(self, xml_response):
		root = ET.fromstring(xml_response)
		response_data = {}
		for elem in root:
			response_data[elem.tag] = elem.text
		return response_data

	def request_routing_label(self, request_data):
		xml_payload = self._build_xml_request("RoutingLabelRequest", request_data)
		headers = {"Content-Type": "application/xml"}
		response = requests.post(self.endpoint, data=xml_payload, headers=headers)
		return self._parse_xml_response(response.text)

	def request_shipping(self, request_data):
		xml_payload = self._build_xml_request("ShippingRequest", request_data)
		headers = {"Content-Type": "application/xml"}
		response = requests.post(self.endpoint, data=xml_payload, headers=headers)
		return self._parse_xml_response(response.text)

	def request_pricing(self, request_data):
		xml_payload = self._build_xml_request("PricingRequest", request_data)
		headers = {"Content-Type": "application/xml"}
		response = requests.post(self.endpoint, data=xml_payload, headers=headers)
		return self._parse_xml_response(response.text)
