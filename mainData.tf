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
 
data "azurerm_resource_group" "main_rg" { 
name = var.rg_name 
} 
 
data "azurerm_virtual_network" "main_vnet" { 
name                = "App_VNET" 
resource_group_name = data.azurerm_resource_group.main_rg.name 
} 
 
resource "azurerm_public_ip" "app01vm_pub_ip" { 
name                = "app01vm_ip" 
resource_group_name = data.azurerm_resource_group.main_rg.name 
  location            = data.azurerm_resource_group.main_rg.location 
  allocation_method   = "Dynamic" 
} 
 
data "azurerm_subnet" "env_subnet" { 
resource_group_name  = data.azurerm_resource_group.main_rg.name 
virtual_network_name = data.azurerm_virtual_network.main_vnet.name 
name                 = var.subnet_name 
} 
 
resource "azurerm_network_interface" "app01vm_nic" { 
  name                = "app01vm-nic" 
  location            = data.azurerm_resource_group.main_rg.location 
resource_group_name = data.azurerm_resource_group.main_rg.name 
ip_configuration { 
    name                          = "internal" 
    subnet_id                     = data.azurerm_subnet.env_subnet.id 
private_ip_address_allocation = "Dynamic" 
public_ip_address_id          = azurerm_public_ip.app01vm_pub_ip.id 
  } 
} 
 