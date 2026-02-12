# Introduction
## What is ERPNext TNT Integration?

This is a [Frappe](https://frappeframework.com/) custom app that integrates TNT Express shipping services into ERPNext by extending the standard Shipment DocType and providing tools to manage the shipping lifecycle.

## Features

- **API Configuration**: Centralized management of TNT Express Connect and Express Label API credentials and endpoints via the `TNT Settings` DocType.
- **Rate Fetching**: Request and select from available TNT shipping services and rates directly from a Shipment document.
- **Shipment Booking**: Book shipments with TNT and store tracking numbers and booking references.
- **Label Generation**: Integration with TNT Express Label API to retrieve and store address labels, routing labels, consignment notes, and manifests.
- **Tracking**:
    - Manual tracking updates via an "Update TNT Tracking" button on Shipments.
    - Automatic daily tracking updates for all active shipments via a scheduled task.
    - Synchronization of tracking status and URLs to linked Delivery Notes.
- **Hazardous Goods Handling**:
    - Detection of hazardous items based on custom fields on the Item DocType.
    - Validation for hazardous weight on Shipment submission.
- **Logging**: `TNT Request Log` records XML requests and responses for troubleshooting.

## Technical Details

- **Overrides**: Extends the standard `Shipment` DocType controller (`CustomShipment`) to add validation logic (e.g., hazardous weight checks, pickup date validation).
- **Fixtures**: Includes custom fields for `Item` and `Shipment` to track hazardous status and weight.
- **UI Hooks**: Custom JavaScript on the Shipment form handles service selection dialogs and API triggers.
- **PDF Customization**: Configurable PDF margins and options for labels via JSON settings in `TNT Settings`.
- **Scheduled Tasks**: A daily background job (`update_tracking_info_daily`) polls TNT for status updates on all shipments not yet marked as "Delivered".

## Under the Hood

- [Frappe Framework](https://frappe.io/framework): A full-stack web application framework written in Python and Javascript. The framework provides a robust foundation for building web applications, including a database abstraction layer, user authentication, and a REST API.


## Installation

Go [here](https://github.com/Starktail/erpnext_tnt) for installation instructions.

## Support

- [Starktail Website](https://starktail.com)
- [Starktail Email Support](mailto:support@starktail.com)
- [Starktail WhatsApp Support](https://wa.me/27686318877?text=Hi%2C%20I%20have%20a%20question%20on%20ERPNext%20TNT%20Integration)
