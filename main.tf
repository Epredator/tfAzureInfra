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

resource "azurerm_resource_group" "main_rg" {
  name     = "etroya_RG"
  location = "West Europe"
}


resource "azurerm_resource_group" "app_data_rg" {
  name     = "App-Data-RG"
  location = "West Europe"
}

resource "azurerm_storage_account" "storage_accoung_rg" {
  name                     = "appdata2234392742894"
  resource_group_name      = azurerm_resource_group.app_data_rg.name
  location                 = azurerm_resource_group.app_data_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_network" "main_vnet" {
  name                = "Terraform_VNET"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  address_space       = ["10.1.0.0/16"]

  subnet {
    name           = "dev_subnet"
    address_prefix = "10.1.1.0/24"
  }

  subnet {
    name           = "test_subnet"
    address_prefix = "10.1.2.0/24"
  }
}
