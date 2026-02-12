import os

import lxml.etree as ET

path = "frappe-bench/apps/erpnext_tnt/docs/print_format_generation/"

print_formats = [
	("consignment_note.xml", "HTMLConsignmentNoteRenderer.xsl"),
	("address_label.xml", "HTMLAddressLabelRenderer.xsl"),
	("manifest.xml", "HTMLManifestRenderer.xsl"),
	("commercial_invoice.xml", "HTMLCommercialInvoiceRenderer.xsl"),
	("routing_label.xml", "HTMLRoutingLabelRenderer.xsl"),
]

# Change the index to select the print format
xml_file, xsl_file = print_formats[4]  # <-|

xml_file = path + xml_file
xsl_file = path + xsl_file

cwd = os.getcwd()

dom = ET.parse(xml_file)
xslt = ET.parse(xsl_file)
transform = ET.XSLT(xslt)
newdom = transform(dom)

with open("output.html", "wb") as f:  # nosemgrep: frappe-security-file-traversal
	f.write(ET.tostring(newdom, pretty_print=True, method="html"))

# Use the output.html file, modify it with Jinja2 and save it as the HTML for the relevant print format
