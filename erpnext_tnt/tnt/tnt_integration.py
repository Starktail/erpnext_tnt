import frappe

from erpnext_tnt.tnt.tnt_api import TNTAPI


def get_tnt_shipping_rate(args):
	"""
	Returns shipping rate information by calling TNT's pricing API.
	'args' should include necessary keys like sender_postal_code, receiver_postal_code, weight, etc.
	"""
	# Retrieve TNT settings (assuming a single record exists)
	tnt_settings = frappe.get_doc("TNT Settings", "TNT Settings")

	tnt_api = TNTAPI(username=tnt_settings.api_username, password=tnt_settings.api_password, endpoint=tnt_settings.api_endpoint, carrier_account=tnt_settings.carrier_account)

	# Map ERPNext shipping fields to TNT pricing request fields
	request_data = {
		"SenderPostalCode": args.get("sender_postal_code"),
		"ReceiverPostalCode": args.get("receiver_postal_code"),
		"Weight": args.get("weight"),
		# Include additional fields (e.g., dimensions) if required
	}

	response = tnt_api.request_pricing(request_data)

	if response.get("Status") == "Success":
		return {"rate": response.get("Rate"), "currency": response.get("Currency", "USD"), "service_code": response.get("ServiceCode")}
	else:
		frappe.throw("TNT Pricing Error: " + response.get("ErrorMessage", "Unknown error"))


def create_tnt_shipment(args):
	"""
	Creates a shipment via TNT and logs the result.
	'args' should include fields like sender_name, receiver_name, receiver_address, weight, and an ERP reference.
	"""
	tnt_settings = frappe.get_cached_doc("TNT Settings", "TNT Settings")

	tnt_api = TNTAPI(username=tnt_settings.api_username, password=tnt_settings.api_password, endpoint=tnt_settings.api_endpoint, carrier_account=tnt_settings.carrier_account)

	# Map ERPNext shipment data to TNT shipping request fields
	request_data = {
		"SenderName": args.get("sender_name"),
		"ReceiverName": args.get("receiver_name"),
		"ReceiverAddress": args.get("receiver_address"),
		"Weight": args.get("weight"),
		# Additional fields as required by TNT API
	}

	response = tnt_api.request_shipping(request_data)

	if response.get("Status") == "Success":
		# Optionally, update the ERPNext shipment record with TNT details
		if args.get("erp_reference"):
			shipment = frappe.get_doc("Delivery Note", args.get("erp_reference"))
			shipment.db_set("tracking_number", response.get("TrackingNumber"))
			shipment.db_set("tnt_shipment_id", response.get("ShipmentID"))

		# Log the shipment details in TNT Shipment doctype
		tnt_shipment = frappe.get_doc(
			{
				"doctype": "TNT Shipment",
				"tnt_shipment_id": response.get("ShipmentID"),
				"erp_reference": args.get("erp_reference"),
				"tracking_number": response.get("TrackingNumber"),
				"status": response.get("Status"),
				"api_response": str(response),
			}
		)
		tnt_shipment.insert()
		return response
	else:
		frappe.throw("TNT Shipment Error: " + response.get("ErrorMessage", "Unknown error"))
