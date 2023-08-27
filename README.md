# Terraform module: Azure DevOps service connection (+ more)

This Terraform module allows you to create service principals (SPN) in Azure AD, assign role assignments in Azure, and create service connections in Azure DevOps.

And, not least, you have the option to automatically rotate the client secret. To take advantage of this feature, you should set up a pipeline to run regularly (each night for example), which runs `terraform apply -auto-approve`. See [Scheduled Terraform run](#scheduled-terraform-run) for examples.

## Required permission
The following permissions are required in order to use this module.

### Azure AD
When authenticated with a _service principal_, this resource requires the following application roles: 

- `Application.ReadWrite.OwnedBy`
- `User.Read.All`

When authenticated with a _user principal_, this resource requires one of the following directory roles:

- `Application Administrator`
- `Global Administrator`

### Azure
If the module is used to create role assignments in Azure, which it needs to do when adding service connections in Azure DevOps, you need to have one of the following roles on the scope you assign the role:

- `Owner`
- `User Access Administrator`
- Or any other role which allows you to assign roles to others.

### Azure DevOps
To create service connections in Azure DevOps, you need to create a [_personal access token (PAT)_](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate) in Azure DevOps.

The PAT needs to be assigned the following scopes:

- Service Connections
  - `Read`
  - `Query`
  - `Manage`

The account issuing the PAT also needs to have the following permission (or higher) in the project(s) it will create service connections:

- `Endpoint Administrators`

## Inputs

| Name | Key | Type | Required/Optional | Default value | Description |
| ---- | --- | ---- | ----------------- | ------------- | ----------- |
| `default_azuredevops_project_name` |  | `string` | Optional | `null` | Default project you want to create service connection in Azure DevOps. Can be overridden for each service with the `azuredevops_project_name` under `service_principals`. |
| `default_owners` |  | `list(string)` | Optional | `[]` | List of UPNs for default owners of the Azure AD application and service principal. These owners will be applied to all applications / service principals created through this module. |
| `service_principals` |  | `map(object)` | Optional | `{}` | Map of objects with name of the service principals to create. The object name will be used as the name for the Azure AD app, service principal and Azure DevOps service connection. |
|  | `owners` | `list(string)` | Optional | `[]` | List of UPNs for owners of the Azure AD application and service principal, in addition to those you possibly added to `default_owners`. |
|  | `auto_rotate_client_secret` | `bool` | Optional | `true` | Option if you want the client secret to rotate during a Terraform run when the rotation interval is reached. |
|  | `client_secret_rotation_interval_in_days` | `number` | Optional | `7` | Client secret rotation interval in days. To have optimal effect, the Terraform run should run automatically and regulary. |
|  | `create_azure_role_assignment` | `bool` | Optional | `false` | Option to create a role assignment in Azure. |
|  | `azure_role_assignment_scope` | `string` | Optional | `null` | Scope where the role assignment should be assigned. |
|  | `azure_role_assignment_name` | `string` | Optional | `Owner` | Name of the role assignment role. E.g. 'Owner', 'Contributor', 'Website Contributor' and so on. |
|  | `create_azure_devops_service_connection` | `bool` | Optional | `true` | Option to create a service connection in Azure DevOps. |
|  | `azuredevops_project_name` | `string` | Optional | `null` | If you want to override the default Azure DevOps project name in `default_azuredevops_project_name`, you can fill out this one. |

## Outputs
| Name | Description |
|------|-------------|
| `application_ids` | Application IDs for the applications / service principals created. |
| `azuread_applications` | All information about Azure AD applications created. |
| `azuread_service_principals` | All information about Azure AD service principals created. |

## Scheduled Terraform run
To take advantage of the option to auto-rotate the client secrets, you should run `terraform apply -auto-approve` automatically and regularly. 

If you use Azure DevOps and Azure Pipelines, you'll find a template for a YAML pipeline you can use here: [pipelines/azure-pipelines-terraform-auto-apply.yaml](https://github.com/robertbrandso/terraform-azuredevops-service-connections/tree/main/pipelines/azure-pipelines-terraform-auto-apply.yaml). The pipeline uses the Azure DevOps extension called [Azure Pipelines Terraform Tasks](https://marketplace.visualstudio.com/items?itemName=charleszipp.azure-pipelines-tasks-terraform).

You can of course use your preferred method of running Terraform, as long as you can schedule a run with auto-approval.

## Example

```hcl
module "example" {
  source  = "robertbrandso/service-connections/azuredevops"
  version = "1.0.0"

  default_owners = [
    "user1@example.com",
    "user2@example.com"
  ]

  default_azuredevops_project_name = "Foo Bar"

  service_principals = {

    "example-dev" = {}

    "example-prod" = {
      auto_rotate_client_secret = false
    }

    "foobar-prod-terraform" = {
      create_azure_devops_service_connection = false
    }

    "foobar-prod" = {
      azure_role_assignment_name  = "Contributor"
      azure_role_assignment_scope = "/subscriptions/91045926-c892-4872-b7f8-1cc86bfac31a/resourceGroups/rg-foobar-prod"
    }

  }
}

output "application_ids" {
  value = module.example.application_ids
}

```
