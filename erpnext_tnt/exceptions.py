from frappe.exceptions import ValidationError


class TNTAPIDisabledError(ValidationError):
	pass


class TNTAPIUnexpectedResponseError(ValidationError):
	pass


class TNTAPIError(ValidationError):
	pass
