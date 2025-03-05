# Copyright (c) 2025, Finfoot Tech (Pty) Ltd and contributors
# For license information, please see license.txt

import json

import frappe
from frappe import _
from frappe.model.document import Document

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
	tnt_shipment.post_to_tnt_express_api()

	return tnt_shipment


class TNTShipment(Document):

	erpnext_shipment_ext = None

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
		self.is_hazardous = False
		shipment = frappe.get_doc("Shipment", self.shipment)
		for dn in shipment.shipment_delivery_note:
			delivery_note = frappe.get_doc("Delivery Note", dn.delivery_note)
			for row in delivery_note.items:
				if frappe.get_value("Item", row.item_code, "custom_tnt_is_hazardous"):
					self.is_hazardous = True
					break

	def _get_settings(self):
		self.tnt_settings = frappe.get_cached_doc("TNT Settings")

	@frappe.whitelist()
	def post_to_tnt_express_api(self):
		"""
		Post the shipment to the TNT Express API
		"""
		self._get_settings()
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

		tnt_api = TNTAPI(dt=self.doctype, dn=self.name)
		result = tnt_api.request_shipping(rendered_xml)

		if result.error:
			return self._raise_error(result.error)

		self.access_code = result.data["access_code"]
		tnt_shipment = result.data["tnt_shipment"]
		self.tnt_shipment_id = tnt_shipment["tnt_shipment_id"]
		self.tracking_number = tnt_shipment["access_code"]
		self.booking_reference = tnt_shipment["tnt_booking_reference"]
		self.shipment_data = json.dumps(tnt_shipment)
		self.error = result.raw_response_text
		self.status = "Created"

		# Opportunistically try to add values to erpnext_shipping fields if they exist
		shipment = frappe.get_doc("Shipment", self.shipment)
		try:
			shipment.db_set(
				{
					"shipment_id": tnt_shipment["access_code"],
					"carrier": "TNT Express",
				}
			)
			if len(shipment.shipment_delivery_note) > 0:
				update_delivery_notes(delivery_note_names=[row.delivery_note for row in shipment.shipment_delivery_note], tracking_number=tnt_shipment["access_code"])
		except Exception as e:
			pass

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

	@frappe.whitelist()
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

		tnt_api = TNTAPI(dt=self.doctype, dn=self.name)
		result = tnt_api.request_rates(rendered_xml)

		if result.error:
			return self._raise_error(result.error, save_to_doc=False)

		result.data["tnt_shipment"] = self.name
		result.data["is_hazardous"] = self.is_hazardous
		result.data["default_service"] = self.tnt_settings.default_service_code
		return result.data


def update_delivery_notes(delivery_note_names, tracking_number: str, carrier="TNT Express"):
	# Update Shipment Info in Delivery Note
	# Using db_set since some fields might not exist
	for delivery_note in delivery_note_names:
		dl_doc = frappe.get_doc("Delivery Note", delivery_note)
		dl_doc.db_set("parcel_service", carrier)
		dl_doc.db_set("tracking_number", tracking_number)
