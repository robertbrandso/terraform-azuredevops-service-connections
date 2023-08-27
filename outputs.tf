# -------
# OUTPUTS
# -------

output "azuread_service_principals" {
  description = "All information about Azure AD service principals created."
  value       = azuread_service_principal.main
}

output "azuread_applications" {
  description = "All information about Azure AD applications created."
  value       = azuread_service_principal.main
}

output "application_ids" {
  description = "Application IDs for the applications / service principals created."
  value       = { for k, v in azuread_application.main : k => v.application_id }
}
