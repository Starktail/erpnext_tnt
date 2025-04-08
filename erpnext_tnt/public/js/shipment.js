
frappe.ui.form.on("Shipment", {
	refresh: function (frm) {

        if (frm.doc.docstatus === 1 && !frm.doc.shipment_id) {
            frm.add_custom_button(__("Fetch TNT Shipping Rates"), function () {
                return frm.events.fetch_tnt_shipping_rates(frm);
            });
        }
		if (frm.doc.shipment_id) {
			if (frm.doc.tracking_status != "Delivered") {
				frm.add_custom_button(
					__("Update TNT Tracking"),
					function () {
						return frm.events.update_tnt_tracking(
							frm,
							frm.doc.service_provider,
							frm.doc.shipment_id
						);
					},
					__("Tools")
				);
			}
		}
	},

	fetch_tnt_shipping_rates: function (frm) {
		if (!frm.doc.shipment_id) {
            frappe.call({
                method: "erpnext_tnt.tnt.doctype.tnt_shipment.tnt_shipment.create_tnt_shipment_doc_and_request_rates",
				freeze: true,
                args: {
                    shipment_name: frm.doc.name
                },
                callback: function(r) {
                    frappe.dom.unfreeze();
                    frappe.show_alert({
                        message:__('Completed successfully'),
                        indicator:'green'
                    }, 5);
                    console.log(r.message);
                    select_from_available_tnt_services(frm, r.message);
                },
                error: (r) => {
                    frappe.dom.unfreeze();
                    frappe.show_alert({
                        message: __('There was an error processing the request. See Error Log.'),
                        indicator: 'red'
                    }, 5);
                }
            });
		} else {
			frappe.throw(__("Shipment already created"));
		}
	},

	update_tnt_tracking: function (frm, service_provider, shipment_id) {
		let delivery_notes = [];
		(frm.doc.shipment_delivery_note || []).forEach((d) => {
			delivery_notes.push(d.delivery_note);
		});
		frappe.call({
			method: "erpnext_tnt.tnt.tasks.update_tnt_tracking",
			freeze: true,
			freeze_message: __("Updating TNT Tracking"),
			args: {
				shipment: frm.doc.name,
				shipment_id: shipment_id,
				delivery_notes: delivery_notes,
			},
			callback: function (r) {
				if (!r.exc) {
					frm.reload_doc();
				}
			},
		});
	},

});


function select_from_available_tnt_services(frm, tnt_data) {
	// Extract the available rates from the provided object
	let rates = tnt_data.rates;
	const default_service = tnt_data.default_service

    // Convert the rate values to numbers
    if (!tnt_data.is_hazardous){
        rates = rates.map(rate => {
            return {
                ...rate,
                totalPrice: parseFloat(rate.totalPrice || "0"),
                totalPriceExclVat: parseFloat(rate.totalPriceExclVat || "0"),
                vatAmount: parseFloat(rate.vatAmount || "0"),
                chargeElements: rate.chargeElements.map(elem => {
                    return {
                        ...elem,
                        chargeValue: parseFloat(elem.chargeValue || "0")
                    };
                })
            };
        });
    }

	// Prioritise the default service (list it at the top)
	if (default_service){
		rates.sort((a, b) => {
		if (a.product.id === default_service && b.product.id !== default_service) {
			return -1;
		}
		if (b.product.id === default_service && a.product.id !== default_service) {
			return 1;
		}
		return 0;
		});
	}

	// Create a dialog for selecting a rate
	const dialog = new frappe.ui.Dialog({
		title: __("Select Service to Create Shipment"),
		size: "extra-large",
		fields: [
			{
				fieldtype: "HTML",
				fieldname: "hazardous_notice",
				label: "",
                options: tnt_data.is_hazardous ? __("<span class='text-danger'>Hazardous shipments are not supported for rate calculation</span>") : "", 
			},
			{
				fieldtype: "HTML",
				fieldname: "available_services",
				label: __("Available Services"),
			},
		],
	});

	// Render the available rates using a template.
	// The header columns have been updated to show relevant rate details.
	dialog.fields_dict.available_services.$wrapper.html(
		frappe.render_template("tnt_shipment_service_selector", {
			header_columns: [
				__("Product ID"),
				__("Description"),
				__("Total Price"),
				__("Price Excl VAT"),
				__("VAT Amount")
			],
			data: rates,
			default_service: default_service
		})
	);

	// Listen for click events on buttons within the dialog.
	// It is assumed that each rendered button has a data attribute "data-index" corresponding to the rate's index.
	dialog.$body.on("click", ".btn", function () {
		// Get the index of the selected rate
		let service_index = parseInt($(this).attr("data-index"));
		let service_data = rates[service_index];
		frm.select_row(service_data);
	});

	// Define what happens when a rate is selected.
	frm.select_row = function (service_data) {
		frappe.call({
			method: "erpnext_tnt.tnt.doctype.tnt_shipment.tnt_shipment.book_tnt_shipment",
			freeze: true,
			freeze_message: __("Creating Shipment"),
			args: {
				tnt_shipment_name: tnt_data.tnt_shipment,
                service_data: service_data
			},
			callback: function (r) {
				if (!r.exc && r.message && r.message.tnt_shipment_id) {
					frm.reload_doc();
					frappe.msgprint({
						message: __("Shipment {0} has been created with TNT", [
							r.message.tnt_shipment_id.bold()
						]),
						title: __("Shipment Created"),
						indicator: "green",
					});
                }
                else {
                    frappe.dom.unfreeze();
                    frappe.show_alert({
                        message: __('There was an error processing the request. See Error Log.'),
                        indicator: 'red'
                    }, 5);
				}
			},
            error: (r) => {
                frappe.dom.unfreeze();
                frappe.show_alert({
                    message: __('There was an error processing the request. See Error Log.'),
                    indicator: 'red'
                }, 5);
            }
		});
		dialog.hide();
	};
	dialog.show();
}
