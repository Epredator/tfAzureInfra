# Content of the main.tf file:
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "hello_word" {
  name     = "Hello_Terraform_RG"
  location = "westus"
}
