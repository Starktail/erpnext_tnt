# Copyright (c) 2025, Finfoot Tech (Pty) Ltd and contributors
# For license information, please see license.txt

import frappe
from frappe import _
from frappe.model.document import Document


class TNTSettings(Document):
	def validate(self):
		"""
		Validate that hazardous_goods_un_number is a 4 digit number
		"""
		if self.hazardous_goods_un_number:
			if not (self.hazardous_goods_un_number.isdigit() and len(self.hazardous_goods_un_number) == 4):
				frappe.throw(_("Hazardous Goods Number must be a 4 digit number"))

