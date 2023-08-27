# ---------
# VARIABLES
# ---------

variable "default_azuredevops_project_name" {
  description = "(Optional) Default project name in Azure DevOps. Can be overridden for each service with the 'azuredevops_project_name' under var.service_principals."
  type        = string
  default     = null
}

variable "default_owners" {
  description = "(Optional) List of UPNs for default owners of the Azure AD application and service principal. These owners will be applied to all applications / service principals created through this module."
  type        = list(string)
  default     = []
}

variable "service_principals" {
  description = "(Optional) Map of objects with name of the service principals to create. Under each object you have several optional options."
  type = map(object({
    owners                                  = optional(list(string), []) # List of UPNs for owners of the Azure AD application and service principal, in addition to those you possibly added to var.default_owners.
    auto_rotate_client_secret               = optional(bool, true)       # Option if you want the client secret to rotate under a Terraform run if rotation interval are hit.
    client_secret_rotation_interval_in_days = optional(number, 7)        # Client secret rotation interval in days. To have optimal effect, the Terraform run should run automatically and regulary.
    create_azure_role_assignment            = optional(bool, false)      # Option to create a role assignment in Azure.
    azure_role_assignment_scope             = optional(string, null)     # Scope where the role assignment should be assigned.
    azure_role_assignment_name              = optional(string, "Owner")  # Name of the role assignment role. E.g. 'Owner', 'Contributor', 'Website Contributor' and so on.
    create_azure_devops_service_connection  = optional(bool, true)       # Option to create a service connection in Azure DevOps.
    azuredevops_project_name                = optional(string, null)     # If you want to override the default Azure DevOps project name in var.default_azuredevops_project_name, you can fill out this one.
  }))
  default = {}
}
