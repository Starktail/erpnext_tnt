import xml.etree.ElementTree as ET


def parse_xml_to_dict(xml_str):
	"""
	Parses an XML string into a nested dictionary.

	Args:
	    xml_str (str): The XML string.

	Returns:
	    dict: A nested dictionary representing the XML structure.
	"""

	def recursive_dict(element):
		node = {}
		# Include attributes, prefixing keys with '@'
		if element.attrib:
			node.update({f"@{k}": v for k, v in element.attrib.items()})

		# Process child elements
		children = list(element)
		if children:
			child_dict = {}
			for child in children:
				child_value = recursive_dict(child)
				# If the tag already exists, group them into a list
				if child.tag in child_dict:
					if isinstance(child_dict[child.tag], list):
						child_dict[child.tag].append(child_value)
					else:
						child_dict[child.tag] = [child_dict[child.tag], child_value]
				else:
					child_dict[child.tag] = child_value
			node.update(child_dict)

		# Process text content if it exists and is not just whitespace
		text = element.text.strip() if element.text else ""
		if text:
			# If there are already other keys (attributes/children), store text under "#text"
			if node:
				node["#text"] = text
			else:
				node = text
		return node

	root = ET.fromstring(xml_str)
	return {root.tag: recursive_dict(root)}
