// Copyright (c) 2025, Finfoot Tech (Pty) Ltd and contributors
// For license information, please see license.txt

frappe.ui.form.on("TNT Shipment", {
  refresh(frm) {
    if (frappe.session.user === "Administrator") {
      frm.add_custom_button(
        __("Fetch and Update Tracking Info"),
        function () {
          frappe.dom.freeze(__("Fetch and Update Tracking Info") + "...");
          frappe.call({
            method: "fetch_tracking_tnt_express_api",
            doc: frm.doc,
            callback: function (r) {
              frappe.dom.unfreeze();
              frappe.show_alert(
                {
                  message: __("Completed successfully"),
                  indicator: "green",
                },
                5,
              );
            },
            error: (r) => {
              frappe.dom.unfreeze();
              frappe.show_alert(
                {
                  message: __(
                    "There was an error processing the request. See Error Log.",
                  ),
                  indicator: "red",
                },
                5,
              );
            },
          });
        },
        __("API Actions"),
      );
    }

    if (frm.perm[0].write) {
      frm.add_custom_button(
        __("Set Status Manually"),
        function () {
          frappe.prompt(
            [
              {
                label: __("Status"),
                fieldname: "status",
                fieldtype: "Select",
                options: frm.get_field("status").df.options,
                default: frm.doc.status,
                reqd: 1,
              },
            ],
            function (values) {
              if (values.status === frm.doc.status) {
                return;
              }
              frm.set_value("status", values.status);
              frm.save().then(() => {
                frappe.show_alert(
                  {
                    message: __("Status updated to {0}", [__(values.status)]),
                    indicator: "green",
                  },
                  5,
                );
              });
            },
            __("Set Status Manually"),
            __("Update"),
          );
        },
        __("Actions"),
      );
    }
  },
});
