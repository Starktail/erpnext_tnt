// Copyright (c) 2025, Finfoot Tech (Pty) Ltd and contributors
// For license information, please see license.txt

frappe.ui.form.on("TNT Shipment", {
	refresh(frm) {
        if (frappe.session.user === "Administrator"){           
            frm.add_custom_button(__("Fetch and Update Tracking Info"), function() {
                frappe.dom.freeze(__("Fetch and Update Tracking Info") + "...");
                frappe.call({
                    method: "fetch_tracking_tnt_express_api",
                    doc: frm.doc,
                    callback: function(r) {
                        frappe.dom.unfreeze();
                        frappe.show_alert({
                            message:__('Completed successfully'),
                            indicator:'green'
                        }, 5);
                    },
                    error: (r) => {
                        frappe.dom.unfreeze();
                        frappe.show_alert({
                            message: __('There was an error processing the request. See Error Log.'),
                            indicator: 'red'
                        }, 5);
                    }
                });
                }, __("API Actions"));
        }
	},
});
