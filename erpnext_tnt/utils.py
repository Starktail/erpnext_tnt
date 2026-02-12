import frappe
from erpnext.setup.utils import enable_all_roles_and_domains
from frappe.utils import now_datetime


def before_tests():
	frappe.clear_cache()
	# complete setup if missing
	from frappe.desk.page.setup_wizard.setup_wizard import setup_complete

	print("Running before_tests")

	if not frappe.db.a_row_exists("Company"):
		print("Running setup_complete because company does not exist")
		current_year = now_datetime().year
		setup_complete(
			{
				"currency": "EUR",
				"full_name": "Test User",
				"company_name": "Sun Power Gmbh",
				"timezone": "Europe/Berlin",
				"company_abbr": "SP",
				"industry": "Manufacturing",
				"country": "Germany",
				"fy_start_date": f"{current_year}-01-01",
				"fy_end_date": f"{current_year}-12-31",
				"language": "english",
				"company_tagline": "Testing",
				"email": "test@erpnext.com",
				"password": "test",
				"chart_of_accounts": "Standard",
			}
		)
	enable_all_roles_and_domains()
	frappe.db.commit()  # nosemgrep
