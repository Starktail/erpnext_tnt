# Copyright (c) 2025, Finfoot Tech (Pty) Ltd and contributors
# For license information, please see license.txt

import json

import frappe
from frappe import _
from frappe.model.document import Document

from erpnext_tnt.tnt.tnt_api import TNTAPI


def get_field_label(doc: Document, field_name: str) -> str:
	field = next(f for f in doc.meta.fields if f.fieldname == field_name)
	return field.label


class TNTShipment(Document):

	erpnext_shipment_ext = None

	def _raise_error(self, err: Exception):
		frappe.log_error(_("TNT API Error for TNT Shipment {0}").format(self.name), err, "TNT Shipment", self.name)
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
			},
		)

		tnt_api = TNTAPI(dt=self.doctype, dn=self.name)
		result = tnt_api.request_shipping(rendered_xml)

		if result.error:
			return self._raise_error(result.error)

		self.access_code = result.data["access_code"]
		tnt_shipment = result.data["tnt_shipment"]
		self.tnt_shipment_id = tnt_shipment["tnt_shipment_id"]
		self.tracking_number = tnt_shipment["tnt_shipment_id"]
		self.booking_reference = tnt_shipment["tnt_booking_reference"]
		self.shipment_data = json.dumps(tnt_shipment)
		self.error = result.raw_response_text
		self.status = "Created"
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
		required_contact_fields = ["phone", "email_id"]
		contact = self.erpnext_shipment_ext.delivery_contact_doc
		for field_name in required_contact_fields:
			if not contact.get(field_name):
				label = get_field_label(contact, field_name)
				frappe.throw(_("Missing required field: {0} for Contact '{1}'").format(frappe.bold(label), frappe.bold(contact.name)))

	def get_company_contact(self):
		user = self.erpnext_shipment_ext.pickup_contact_person
		company_contact = frappe.db.get_value("User", user, ["full_name", "last_name", "email", "phone", "mobile_no"], as_dict=True)

		if not (company_contact.last_name and company_contact.email and (company_contact.phone or company_contact.mobile_no)):
			frappe.throw(
				_("Last Name, Email or Phone/Mobile of the user are mandatory to continue.") + "</br>" + _("Please first set Last Name, Email and Phone for the user") + f' <a href="/app/user/${user}">${user}</a>'
			)
		self.erpnext_shipment_ext.pickup_contact_person_dict = company_contact
