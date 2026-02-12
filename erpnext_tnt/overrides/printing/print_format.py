import json

import frappe
from frappe.translate import print_language
from frappe.www.printview import validate_print_permission


@frappe.whitelist(allow_guest=True)
def custom_download_pdf(
	doctype, name, format=None, doc=None, no_letterhead=0, language=None, letterhead=None
):
	"""
	Custom version of download_pdf to set "margin-right" and "margin-left" in options, otherwise these would default to "15mm",
	which breaks the TNT Label Print Formats
	"""
	# ===========================================================================================================
	# Original Code
	# ===========================================================================================================
	doc = doc or frappe.get_doc(doctype, name)
	validate_print_permission(doc)

	with print_language(language):
		# pdf_file = frappe.get_print(
		# 	doctype, name, format, doc=doc, as_pdf=True, letterhead=letterhead, no_letterhead=no_letterhead
		# )
		# ===========================================================================================================

		# ===========================================================================================================
		# Custom Code
		# ===========================================================================================================
		pdf_options = {}
		if doctype == "TNT Shipment":
			tnt_settings = frappe.get_cached_doc("TNT Settings")
			if tnt_settings.pdf_options:
				pdf_options_per_print_format = json.loads(tnt_settings.pdf_options)
				if format in pdf_options_per_print_format:
					pdf_options = pdf_options_per_print_format[format]
		pdf_file = frappe.get_print(
			doctype,
			name,
			format,
			doc=doc,
			as_pdf=True,
			letterhead=letterhead,
			no_letterhead=no_letterhead,
			pdf_options=pdf_options,
		)
	# ===========================================================================================================

	frappe.local.response.filename = "{name}.pdf".format(name=name.replace(" ", "-").replace("/", "-"))
	frappe.local.response.filecontent = pdf_file
	frappe.local.response.type = "pdf"
