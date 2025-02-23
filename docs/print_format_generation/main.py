import lxml.etree as ET

print_formats = [
	("consignment_note.xml", "HTMLConsignmentNoteRenderer.xsl"),
	("address_label.xml", "HTMLAddressLabelRenderer.xsl"),
	("manifest.xml", "HTMLManifestRenderer.xsl"),
	("commercial_invoice.xml", "HTMLCommercialInvoiceRenderer.xsl"),
]

# Change the index to select the print format
xml_file, xsl_file = print_formats[0]  # <-|

dom = ET.parse(xml_file)
xslt = ET.parse(xsl_file)
transform = ET.XSLT(xslt)
newdom = transform(dom)

with open("output.html", "wb") as f:
	f.write(ET.tostring(newdom, pretty_print=True, method="html"))

# Use the output.html file, modify it with Jinja2 and save it as the HTML for the relevant print format
