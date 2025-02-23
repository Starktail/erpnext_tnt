// Copyright (c) 2025, Finfoot Tech (Pty) Ltd and contributors
// For license information, please see license.txt

frappe.ui.form.on("TNT Request Log", {
	refresh(frm) {
        // Add a custom button to trigger the processing
        frm.add_custom_button(__("Show URL Decoded Data"), function() {
            let dataStr = frm.doc.data;
            if (dataStr) {
                // Remove all double quotes
				dataStr = dataStr.replace(/^"+|"+$/g, '');
                // Remove 'xml_in=' from the start if it exists
                if (dataStr.startsWith('xml_in=')) {
                    dataStr = dataStr.substring(7);
                }
                // URL decode the string
                const decodedStr = decodeURIComponent(dataStr);
                console.log(decodedStr)
				// Create a dialog with a read-only Code field
				let dialog = new frappe.ui.Dialog({
					title: 'Decoded Data',
					fields: [
						{
							fieldname: 'decoded_data',
							label: 'Decoded Data',
							fieldtype: 'Code',
							default: decodedStr,
                            options: "XML"
						}
					]
				});
				dialog.show();
            } else {
                frappe.msgprint(__('No data available.'));
            }
        });
	},
});
