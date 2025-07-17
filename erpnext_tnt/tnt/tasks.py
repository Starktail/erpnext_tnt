import json

import frappe


@frappe.whitelist()
def update_tnt_tracking(shipment, shipment_id, delivery_notes=None):
	if delivery_notes is None:
		delivery_notes = []

	tnt_shipments = frappe.get_list("TNT Shipment", {"shipment": shipment, "tracking_number": shipment_id})
	if len(tnt_shipments) == 0:
		return

	tnt_shipment = frappe.get_doc("TNT Shipment", tnt_shipments[0].name)

	# Update Tracking info in Shipment
	tracking_data = tnt_shipment.fetch_tracking_tnt_express_api()

	if not tracking_data:
		return

	shipment = frappe.get_doc("Shipment", shipment)
	shipment.db_set(
		{
			"awb_number": tracking_data.get("awb_number"),
			"tracking_status": tracking_data.get("tracking_status"),
			"tracking_status_info": tracking_data.get("tracking_status_info"),
			"tracking_url": tracking_data.get("tracking_url"),
		}
	)

	if delivery_notes:
		update_delivery_note(delivery_notes=delivery_notes, tracking_info=tracking_data)


def update_delivery_note(delivery_notes, shipment_info=None, tracking_info=None):
	# Update Shipment Info in Delivery Note
	# Using db_set since some services might not exist
	if isinstance(delivery_notes, str):
		delivery_notes = json.loads(delivery_notes)

	delivery_notes = list(set(delivery_notes))

	for delivery_note in delivery_notes:
		dl_doc = frappe.get_doc("Delivery Note", delivery_note)
		if shipment_info:
			dl_doc.db_set("delivery_type", "Parcel Service")
			dl_doc.db_set("parcel_service", shipment_info.get("carrier"))
			dl_doc.db_set("parcel_service_type", shipment_info.get("carrier_service"))
		if tracking_info:
			dl_doc.db_set("tracking_number", tracking_info.get("awb_number"))
			dl_doc.db_set("tracking_url", tracking_info.get("tracking_url"))
			dl_doc.db_set("tracking_status", tracking_info.get("tracking_status"))
			dl_doc.db_set("tracking_status_info", tracking_info.get("tracking_status_info"))


def update_tracking_info_daily():
	"""Daily scheduled event to update Tracking info for not delivered Shipments

	Also Updates the related Delivery Notes.
	"""

	shipments = frappe.get_all(
		"Shipment",
		filters={
			"docstatus": 1,
			"status": "Booked",
			"shipment_id": ["!=", ""],
			"tracking_status": ["!=", "Delivered"],
			"carrier": "TNT Express",
		},
	)
	for shipment in shipments:
		shipment_doc = frappe.get_doc("Shipment", shipment.name)
		tracking_info = update_tnt_tracking(
			shipment.name,
			shipment_doc.shipment_id,
			[dn.delivery_note for dn in shipment_doc.shipment_delivery_note],
		)

		if tracking_info:
			fields = ["awb_number", "tracking_status", "tracking_status_info", "tracking_url"]
			for field in fields:
				shipment_doc.db_set(field, tracking_info.get(field))
