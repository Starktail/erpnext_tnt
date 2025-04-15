# Copyright (c) 2020, Frappe Technologies Pvt. Ltd. and contributors
# For license information, please see license.txt

from datetime import datetime

import frappe
from erpnext.stock.doctype.shipment.shipment import Shipment
from frappe import _
from frappe.utils import get_time


class CustomShipment(Shipment):
	def validate(self):
		self.check_if_shipment_contains_hazardous_items()
		super().validate()

	def on_submit(self):
		self.validate_custom_tnt_hazardous_weight()
		super().on_submit()

	def check_if_shipment_contains_hazardous_items(self):
		"""
		Check if the linked shipment contains any hazardous items
		"""
		for dn in self.shipment_delivery_note:
			delivery_note = frappe.get_doc("Delivery Note", dn.delivery_note)
			for row in delivery_note.items:
				if frappe.get_value("Item", row.item_code, "custom_tnt_is_hazardous"):
					self.custom_tnt_is_hazardous = True
					break

	def validate_custom_tnt_hazardous_weight(self):
		"""
		Validate the weight of the shipment if it contains hazardous items
		"""
		if self.custom_tnt_is_hazardous and self.custom_tnt_hazardous_weight <= 0:
			frappe.throw(_("Hazardous Weight can not be 0"))

	def validate_pickup_date_time_in_future(self):
		"""
		Validate that the pickup date and time is in the future
		"""
		if self.pickup_date and self.pickup_from:
			pickup_datetime = datetime.combine(self.pickup_date, get_time(self.pickup_from))
			if pickup_datetime <= frappe.utils.now_datetime():
				frappe.throw(_("Pickup Date and Time must be in the future"))
		else:
			frappe.throw(_("Pickup Date and Time must be set"))
