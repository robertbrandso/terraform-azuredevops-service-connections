terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.36.0" # Not tested on versions below, but will probably work
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.3.0" # Not tested on versions below, but will probably work
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}
