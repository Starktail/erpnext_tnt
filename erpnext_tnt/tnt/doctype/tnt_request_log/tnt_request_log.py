# Copyright (c) 2025, Finfoot Tech (Pty) Ltd and contributors
# For license information, please see license.txt

import frappe
from frappe.model.document import Document


class TNTRequestLog(Document):
	@staticmethod
	def clear_old_logs(days=30):
		from frappe.query_builder import Interval
		from frappe.query_builder.functions import Now

		table = frappe.qb.DocType("TNT Request Log")
		frappe.db.delete(table, filters=(table.modified < (Now() - Interval(days=days))))
