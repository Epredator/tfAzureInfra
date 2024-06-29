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


resource "azurerm_public_ip" "dev01vm_pub_ip" {
name = "dev01vm_ip"
resource_group_name = azurerm_resource_group.main_rg.name
 location = azurerm_resource_group.main_rg.location
 allocation_method = "Dynamic"
}

resource "azurerm_network_interface" "dev01vm_nic" {
 name = "dev01vm-nic"
 location = azurerm_resource_group.main_rg.location
resource_group_name = azurerm_resource_group.main_rg.name
ip_configuration {
 name = "internal"
 subnet_id = azurerm_virtual_network.main_vnet.subnet.*.id[0]
private_ip_address_allocation = "Dynamic"
public_ip_address_id = azurerm_public_ip.dev01vm_pub_ip.id
 }
}

resource "azurerm_network_security_group" "nsg_ssh" {
 name = "dev01vm-nsg"
 location = azurerm_resource_group.main_rg.location
resource_group_name = azurerm_resource_group.main_rg.name
security_rule {
 name = "SSH"
 priority = 300
 direction = "Inbound"
 access = "Allow"
 protocol = "Tcp"
 source_port_range = "*"
 destination_port_range = "22"
 source_address_prefix = ""
destination_address_prefix = "*"
 }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
network_interface_id = azurerm_network_interface.dev01vm_nic.id
network_security_group_id = azurerm_network_security_group.nsg_ssh.id
}

resource "azurerm_linux_virtual_machine" "dev01vm" {
name = "dev01vm"
resource_group_name = azurerm_resource_group.main_rg.name
 location = azurerm_resource_group.main_rg.location
 size = "Standard_B2s"
network_interface_ids = [
azurerm_network_interface.dev01vm_nic.id,
 ]
admin_username = "azureuser"
admin_ssh_key {
username = "azureuser"
public_key = file("./.ssh/id_rsa.pub")
 }
os_disk {
caching = "ReadWrite"
storage_account_type = "Standard_LRS"
 }
source_image_reference {
publisher = "canonical"
 offer = "0001-com-ubuntu-server-jammy"
 sku = "22_04-lts-gen2"
 version = "latest"
 }
}
