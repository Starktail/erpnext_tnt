# Copyright (c) 2025, Finfoot Tech (Pty) Ltd and contributors
# For license information, please see license.txt

import json
from typing import Dict

import frappe
from frappe import ValidationError, _
from frappe.model.document import Document
from requests.auth import HTTPBasicAuth

from erpnext_tnt.tnt.tnt_api import TNTAPI

TNT_SERVICES = [
	("08C", "8:00 Pharma Express"),
	("09C", "9:00 Pharma Express"),
	("10C", "10:00 Pharma Express"),
	("08N", "8:00 Express"),
	("08B", "8:00 Business Pak"),
	("660", "Express Plus 12:00 Delivery"),
	("12C", "12:00 Pharma Express"),
	("15C", "Pharma Express"),
	("09N", "9:00 Express"),
	("10N", "10:00 Express"),
	("09B", "9:00 Business Pak"),
	("10B", "10:00 Business Pak"),
	("12N", "12:00 Express"),
	("15N", "Express"),
	("12B", "12:00 Business Pak"),
]


def get_field_label(doc: Document, field_name: str) -> str:
	field = next(f for f in doc.meta.fields if f.fieldname == field_name)
	return field.label


@frappe.whitelist()
def create_tnt_shipment_doc_and_request_rates(shipment_name: str):
	"""
	Create a new TNT Shipment document from a linked Shipment document
	"""
	shipment = frappe.get_doc("Shipment", shipment_name)
	shipment.validate_pickup_date_time_in_future()
	tnt_shipment = frappe.new_doc("TNT Shipment")
	tnt_shipment.shipment = shipment.name
	tnt_shipment.save()

	return tnt_shipment.fetch_rates_from_tnt_express_api()


@frappe.whitelist()
def book_tnt_shipment(tnt_shipment_name: str, service_data: str):
	"""
	Books a TNT Shipment document from a linked Shipment document
	"""
	tnt_shipment = frappe.get_doc("TNT Shipment", tnt_shipment_name)
	service_data = json.loads(service_data)
	tnt_shipment.tnt_service = service_data["product"]["id"]
	tnt_shipment.save()
	err = tnt_shipment.post_to_tnt_express_api()

	# Get the labels
	if not err:
		tnt_shipment.get_labels()

	return tnt_shipment


class TNTShipment(Document):

	erpnext_shipment_ext = None
	shipping_auth: HTTPBasicAuth = None
	label_auth: HTTPBasicAuth = None

	def _raise_error(self, err: Exception, save_to_doc=True):
		frappe.log_error(_("TNT API Error for TNT Shipment {0}").format(self.name), err, "TNT Shipment", self.name)
		if save_to_doc:
			self.status = "Error"
			self.error = str(err)
			self.save()
		return err

	def check_if_shipment_contains_hazardous_items(self):
		"""
		Check if the linked shipment contains any hazardous items
		"""
		self.is_hazardous = frappe.get_value("Shipment", self.shipment, "custom_tnt_is_hazardous")

	def _get_settings(self):
		self.tnt_settings = frappe.get_cached_doc("TNT Settings")
		self.shipping_auth = HTTPBasicAuth(self.tnt_settings.shipping_api_username, self.tnt_settings.get_password("shipping_api_password"))
		self.label_auth = HTTPBasicAuth(self.tnt_settings.label_api_username, self.tnt_settings.get_password("label_api_password"))

	def post_to_tnt_express_api(self):
		"""
		Post the shipment to the TNT Express API
		"""
		self._get_settings()
		if not self.tnt_settings.shipping_enabled:
			raise ValidationError(_("Shipping is not enabled in TNT Settings"))
		self.load_linked_erpnext_shipment()
		self.validate_linked_erpnext_shipment()
		self.check_if_shipment_contains_hazardous_items()
		self.error = ""

		rendered_xml = frappe.render_template(
			"erpnext_tnt/templates/xml/ship.xml",
			context={
				"username": self.tnt_settings.shipping_api_username,
				"password": self.tnt_settings.get_password("shipping_api_password"),
				"tnt_account": self.tnt_settings.tnt_account,
				"vat_number": self.tnt_settings.company_vat_number,
				"is_hazardous": self.is_hazardous,
				"hazardous_goods_un_number": self.tnt_settings.hazardous_goods_un_number,
				"shipment": self.erpnext_shipment_ext,
				"tnt_service": self.tnt_service,
			},
		)

		tnt_api = TNTAPI(dt=self.doctype, dn=self.name, auth=self.shipping_auth)
		result = tnt_api.request_shipping(rendered_xml)

		if result.error:
			return self._raise_error(result.error)

		self.access_code = result.data["access_code"]
		tnt_shipment = result.data["tnt_shipment"]
		self.tnt_shipment_id = tnt_shipment["tnt_shipment_id"]
		self.tracking_number = tnt_shipment["tnt_shipment_id"][2:-2]
		self.booking_reference = tnt_shipment["tnt_booking_reference"]
		self.shipment_data = json.dumps(tnt_shipment)
		self.error = result.raw_response_text
		self.status = "Created"

		# Opportunistically try to add values to erpnext_shipping fields if they exist
		shipment = frappe.get_doc("Shipment", self.shipment)
		try:
			shipment.db_set(
				{
					"shipment_id": tnt_shipment["tnt_shipment_id"][2:-2],
					"carrier": "TNT Express",
				}
			)
			if len(shipment.shipment_delivery_note) > 0:
				update_delivery_notes(delivery_note_names=[row.delivery_note for row in shipment.shipment_delivery_note], tracking_number=tnt_shipment["tnt_shipment_id"][2:-2])
		except Exception as e:
			pass

		self.save()

	def get_labels(self):
		"""
		Get the label XML data from the TNT Express API
		"""
		if not self.tnt_settings.labels_enabled:
			pass

		tnt_api = TNTAPI(dt=self.doctype, dn=self.name, auth=self.shipping_auth, access_code=self.access_code)

		# TNT Address Label
		result = tnt_api.request_label_data(command_keyword="GET_LABEL")
		if result.error:
			return self._raise_error(result.error)
		self.label_data = result.data
		self.save()

		# TNT Consignment Note
		result = tnt_api.request_label_data(command_keyword="GET_CONNOTE")
		if result.error:
			return self._raise_error(result.error)
		self.connote_data = result.data
		self.save()

		# TNT Manifest
		result = tnt_api.request_label_data(command_keyword="GET_MANIFEST")
		if result.error:
			return self._raise_error(result.error)
		self.manifest_data = result.data
		self.save()

		# TNT Routing Label
		product_line_of_business, product_id, product_type = get_product_details(service_code=self.tnt_service)
		rendered_xml = frappe.render_template(
			"erpnext_tnt/templates/xml/routing_label.xml",
			context={
				"tnt_account": self.tnt_settings.tnt_account,
				"vat_number": self.tnt_settings.company_vat_number,
				"is_hazardous": self.is_hazardous,
				"shipment": self.erpnext_shipment_ext,
				"consignment_number": self.tnt_shipment_id[2:-2],  # e.g. GE981432666DE = 981432666
				"product_line_of_business": product_line_of_business,
				"product_id": product_id,
				"product_type": product_type,
			},
		)

		tnt_api = TNTAPI(dt=self.doctype, dn=self.name, auth=self.label_auth)
		result = tnt_api.request_routing_label_data(rendered_xml)

		if result.error:
			return self._raise_error(result.error)

		self.routing_label_data = result.data
		self.save()

	def load_linked_erpnext_shipment(self):
		"""
		Get the linked ERPNext shipment doc and load linked address docs
		"""
		self.erpnext_shipment_ext = frappe.get_doc("Shipment", self.shipment)

		# Do necessary formatting and get extra data
		self.erpnext_shipment_ext.pickup_date_formatted = frappe.utils.format_date(self.erpnext_shipment_ext.pickup_date, "dd/mm/yyyy")
		self.erpnext_shipment_ext.pickup_from_formatted = frappe.utils.format_time(self.erpnext_shipment_ext.pickup_from, "HH:mm")
		self.erpnext_shipment_ext.pickup_to_formatted = frappe.utils.format_time(self.erpnext_shipment_ext.pickup_to, "HH:mm")
		self.erpnext_shipment_ext.customer_name = frappe.get_value("Customer", self.erpnext_shipment_ext.delivery_customer, "customer_name")
		self.erpnext_shipment_ext.tnt_total_items_count = sum([item.count for item in self.erpnext_shipment_ext.shipment_parcel])
		self.erpnext_shipment_ext.tnt_total_weight = sum([item.weight for item in self.erpnext_shipment_ext.shipment_parcel])
		self.erpnext_shipment_ext.tnt_total_volume = sum([(item.length * item.width * item.height) / 1000000 for item in self.erpnext_shipment_ext.shipment_parcel])
		self.erpnext_shipment_ext.tnt_currency = frappe.get_value("Company", self.erpnext_shipment_ext.pickup_company, "default_currency")

		# Load the linked address docs
		self.erpnext_shipment_ext.pickup_addr_doc = frappe.get_doc("Address", self.erpnext_shipment_ext.pickup_address_name)
		self.erpnext_shipment_ext.delivery_addr_doc = frappe.get_doc("Address", self.erpnext_shipment_ext.delivery_address_name)

		# Load the country codes for each address
		self.erpnext_shipment_ext.pickup_addr_doc.country_code = frappe.get_value("Country", self.erpnext_shipment_ext.pickup_addr_doc.country, "code")
		self.erpnext_shipment_ext.delivery_addr_doc.country_code = frappe.get_value("Country", self.erpnext_shipment_ext.delivery_addr_doc.country, "code")

		# Load the linked contact docs
		self.erpnext_shipment_ext.delivery_contact_doc = frappe.get_doc("Contact", self.erpnext_shipment_ext.delivery_contact_name)
		self.get_company_contact()

	def validate_linked_erpnext_shipment(self):
		"""
		Validate the linked shipment
		"""
		if not self.erpnext_shipment_ext:
			raise frappe.ValidationError()

		# Validate required fields on shipment
		required_shipment_fields = ["pickup_company", "pickup_address", "delivery_customer"]
		for field_name in required_shipment_fields:
			if not self.erpnext_shipment_ext.get(field_name):
				label = get_field_label(self.erpnext_shipment_ext, field_name)
				frappe.throw(_("Missing required field on Shipment: {0}").format(frappe.bold(label)))
		if self.erpnext_shipment_ext.pickup_from_type != "Company":
			label = get_field_label(self.erpnext_shipment_ext, "pickup_from_type")
			frappe.throw(_("{0} of type {1} is not supported").format(frappe.bold(label), frappe.bold(self.erpnext_shipment_ext.pickup_from_type)))

		# Validate linked delivery note(s)
		if len(self.erpnext_shipment_ext.shipment_delivery_note) == 0:
			frappe.throw(_("No Delivery Notes linked to Shipment"))

		# Validate required fields on parcel items
		if len(self.erpnext_shipment_ext.shipment_parcel) == 0:
			frappe.throw(_("No Parcels linked to Shipment"))
		for row in self.erpnext_shipment_ext.shipment_parcel:
			if not (row.length and row.width and row.height):
				frappe.throw(_("Missing dimensions on Parcel Item in row {0}").format(frappe.bold(row.idx)))

		# Validate required fields on addresses
		required_address_fields = ["address_line1", "city", "country", "pincode"]
		for addr in [self.erpnext_shipment_ext.pickup_addr_doc, self.erpnext_shipment_ext.delivery_addr_doc]:
			for field_name in required_address_fields:
				if not addr.get(field_name):
					label = get_field_label(addr, field_name)
					frappe.throw(_("Missing required field: {0} for Address '{1}'").format(frappe.bold(label), frappe.bold(addr.name)))

		# Validate required fields on contacts
		contact = self.erpnext_shipment_ext.delivery_contact_doc
		if not contact.get("email_id"):
			label = get_field_label(contact, "email_id")
			frappe.throw(_("Missing required field: {0} for Contact '{1}'").format(frappe.bold(label), frappe.bold(contact.name)))

		# Validate that either phone or mobile_no is set on Contact
		if not contact.get("phone") and not contact.get("mobile_no"):
			label = get_field_label(contact, "phone") + "/" + get_field_label(contact, "mobile_no")
			frappe.throw(_("Missing required field: {0} for Contact '{1}'").format(frappe.bold(label), frappe.bold(contact.name)))

	def get_company_contact(self):
		user = self.erpnext_shipment_ext.pickup_contact_person
		company_contact = frappe.db.get_value("User", user, ["full_name", "last_name", "email", "phone", "mobile_no"], as_dict=True)

		if not (company_contact.last_name and company_contact.email and (company_contact.phone or company_contact.mobile_no)):
			frappe.throw(
				_("Last Name, Email or Phone/Mobile of the user are mandatory to continue.") + "</br>" + _("Please first set Last Name, Email and Phone for the user") + f' <a href="/app/user/${user}">${user}</a>'
			)
		self.erpnext_shipment_ext.pickup_contact_person_dict = company_contact

	def fetch_rates_from_tnt_express_api(self):
		"""
		Fetch shipping rates from the TNT Express API
		"""
		self._get_settings()
		self.load_linked_erpnext_shipment()
		self.validate_linked_erpnext_shipment()
		self.check_if_shipment_contains_hazardous_items()

		# Price check for hazardous shipments are not supported, so just return a list of standard rates
		if self.is_hazardous:
			return {
				"tnt_shipment": self.name,
				"is_hazardous": True,
				"default_service": self.tnt_settings.default_service_code,
				"rates": [{"product": {"id": service_code, "productDesc": service_descr}} for service_code, service_descr in TNT_SERVICES],
			}

		rendered_xml = frappe.render_template(
			"erpnext_tnt/templates/xml/price_check.xml",
			context={
				"username": self.tnt_settings.shipping_api_username,
				"password": self.tnt_settings.get_password("shipping_api_password"),
				"tnt_account": self.tnt_settings.tnt_account,
				"vat_number": self.tnt_settings.company_vat_number,
				"is_hazardous": self.is_hazardous,
				"hazardous_goods_un_number": self.tnt_settings.hazardous_goods_un_number,
				"shipment": self.erpnext_shipment_ext,
			},
		)

		tnt_api = TNTAPI(dt=self.doctype, dn=self.name, auth=self.shipping_auth)
		result = tnt_api.request_rates(rendered_xml)

		if result.error:
			return self._raise_error(result.error, save_to_doc=False)

		result.data["tnt_shipment"] = self.name
		result.data["is_hazardous"] = self.is_hazardous
		result.data["default_service"] = self.tnt_settings.default_service_code
		return result.data

	@frappe.whitelist()
	def fetch_tracking_tnt_express_api(self) -> Dict:
		"""
		Fetch tracking info from the TNT Express API
		"""
		self._get_settings()

		rendered_xml = frappe.render_template(
			"erpnext_tnt/templates/xml/track.xml",
			context={
				"consignment_number": self.tnt_shipment_id[2:-2],  # e.g. GE981432666DE = 981432666
			},
		)

		tnt_api = TNTAPI(dt=self.doctype, dn=self.name, auth=self.shipping_auth)
		result = tnt_api.request_tracking_data(rendered_xml)

		if result.error:
			return self._raise_error(result.error)

		# TNT API returns a list of consignment data in some scenarios, but we only need the first one
		consignment_data = result.data["TrackResponse"]["Consignment"][0] if type(result.data["TrackResponse"]["Consignment"]) is list else result.data["TrackResponse"]["Consignment"]
		if consignment_data["SummaryCode"] == "EXC":
			self.status = "Exception"
		elif consignment_data["SummaryCode"] == "INT":
			self.status = "In Transit"
		elif consignment_data["SummaryCode"] == "DEL":
			self.status = "Delivered"

		self.save()

		return {
			"awb_number": self.tnt_shipment_id[2:-2],  # e.g. GE981432666DE = 981432666
			"tracking_status": self.status,
			"tracking_status_info": consignment_data["DeliveryDate"]["#text"] if "DeliveryDate" in consignment_data else "",
			"tracking_url": None,
		}


def update_delivery_notes(delivery_note_names, tracking_number: str, carrier="TNT Express"):
	# Update Shipment Info in Delivery Note
	# Using db_set since some fields might not exist
	for delivery_note in delivery_note_names:
		dl_doc = frappe.get_doc("Delivery Note", delivery_note)
		dl_doc.db_set("parcel_service", carrier)
		dl_doc.db_set("tracking_number", tracking_number)


def get_label_data(tnt_shipment_name: str, field_name: str):
	"""
	Get the label data in dict format. Intended as a Jinja method in Print Formats

	field_name should be one of:
	        label_data
	        connote_data
	        manifest_data
	        routing_label_data
	"""
	if field_name not in ["label_data", "connote_data", "manifest_data", "routing_label_data"]:
		raise ValueError()

	tnt_shipment = frappe.get_doc("TNT Shipment", tnt_shipment_name)
	string_data = getattr(tnt_shipment, field_name)
	return json.loads(string_data)


def get_product_details(service_code):
	"""
	Product Details map as extracted from docs/ExpressLabel_TNT-Productcodes.doc
	"""
	PRODUCT_DETAILS = {
		"08D": ("1", "EP08", "D"),
		"09D": ("1", "EP09", "D"),
		"10D": ("1", "EP10", "D"),
		"12D": ("1", "EP12", "D"),
		"15D": ("1", "EP", "D"),
		"08N": ("1", "EP08", "N"),
		"09N": ("1", "EP09", "N"),
		"10N": ("1", "EP10", "N"),
		"12N": ("1", "EP12", "N"),
		"15N": ("1", "EP", "N"),
	}

	return PRODUCT_DETAILS[service_code]
