#!/bin/bash

# This is used in pacakge.json to block the help pages from public access, and copy the assets to the correct directory

AUTH_CONTENT="import frappe
from frappe import _

if frappe.session.user=='Guest':
    frappe.throw(_(\"You need to be logged in to access this page\"), frappe.PermissionError)"

for file in erpnext_tnt/www/erpnext_tnt_*.html; do
  if [ -f "$file" ]; then
    py_file="erpnext_tnt/www/$(basename "$file" .html).py"
    echo "$AUTH_CONTENT" > "$py_file"
  fi
done

rm -rf ./erpnext_tnt/public/chunks
mv ./erpnext_tnt/www/assets/erpnext_tnt/chunks ./erpnext_tnt/public/.
mv ./erpnext_tnt/www/assets/erpnext_tnt/*.js ./erpnext_tnt/public/.
mv ./erpnext_tnt/www/assets/erpnext_tnt/*.css ./erpnext_tnt/public/.