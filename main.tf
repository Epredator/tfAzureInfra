# Provider block
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider 
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "main_rg" {
  name     = var.rg_name
  location = var.location
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
  name                = "App_VNET"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  address_space       = [var.vnet_addressspace]

  subnet {
    name           = "dev_subnet"
    address_prefix = "10.1.1.0/24"
  }

  subnet {
    name           = "test_subnet"
    address_prefix = "10.1.2.0/24"
  }
}


resource "azurerm_public_ip" "vm_pub_ip" {
  count               = var.number_vm
  name                = "${local.prefix}-${format("%02s", count.index)}-ip"
  resource_group_name = azurerm_resource_group.main_rg.name
  location            = azurerm_resource_group.main_rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "app01vm_nic" {
  name                = "${local.prefix}-nic"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_virtual_network.main_vnet.subnet.*.id[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app01vm_pub_ip.id
  }
}

resource "azurerm_network_security_group" "nsg_rdp" {
  name                = "${local.prefix}-nsg"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  security_rule {
    name                       = "RDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.app01vm_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_rdp.id
}

# resource "azurerm_linux_virtual_machine" "app02vm" {
#   name                = "app01vm"
#   resource_group_name = azurerm_resource_group.main_rg.name
#   location            = azurerm_resource_group.main_rg.location
#   size                = "Standard_B2s"
#   network_interface_ids = [
#     azurerm_network_interface.app01vm_nic.id,
#   ]
#   admin_username = "azureuser"
#   admin_ssh_key {
#     username   = "azureuser"
#     public_key = file("C:/Users/Adam/.ssh/id_rsa.pub")
#   }
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }
#   source_image_reference {
#     publisher = "canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts-gen2"
#     version   = "latest"
#   }
# }

resource "azurerm_windows_virtual_machine" "app01vm" {
  name                = "${local.prefix}-vm"
  resource_group_name = azurerm_resource_group.main_rg.name
  location            = azurerm_resource_group.main_rg.location
  size                = "Standard_B2s"
  network_interface_ids = [
    azurerm_network_interface.app01vm_nic.id,
  ]

  admin_username = var.admin_username
  admin_password = var.admin_password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-ent"
    version   = "latest"
  }
  tags = merge(var.tags, local.tags)
}

# resource "azurerm_managed_disk" "disk_data" {
#   name                 = var.disk_names[0]
#   location             = azurerm_resource_group.main_rg.location
#   resource_group_name  = azurerm_resource_group.main_rg.name
#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = 1
# }

# resource "azurerm_managed_disk" "disk_log" {
#   name                 = var.disk_names[1]
#   location             = azurerm_resource_group.main_rg.location
#   resource_group_name  = azurerm_resource_group.main_rg.name
#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = 1
# }

resource "azurerm_managed_disk" "disks" {
  for_each             = var.disks
  name                 = "${local.prefix}-${each.key}"
  location             = azurerm_resource_group.main_rg.location
  resource_group_name  = azurerm_resource_group.main_rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = each.value.size
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_data_attachment" {
  for_each           = var.disks
  managed_disk_id    = azurerm_managed_disk.disks[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.app01vm.id
  lun                = each.value.lun
  caching            = each.value.cache
}


# resource "azurerm_virtual_machine_data_disk_attachment" "disk_data_attachment" {
#   managed_disk_id    = azurerm_managed_disk.disk_data.id
#   virtual_machine_id = azurerm_windows_virtual_machine.app01vm.id
#   lun                = var.disk_lunes[1]
#   caching            = var.disk_caches[1]
# }

locals {
  prefix = "${var.app_code}-${var.vm_name}"
  tags = {
    create_date = formatdate("YYYY-MM-DD", timestamp())
    create_time = formatdate("HH:mm:ss", timestamp())
  }
}

output "public_ip" {
  value       = azurerm_public_ip.app01vm_pub_ip.ip_address
  description = "Server IP"
}

output "admin_username" {
  value       = azurerm_linux_virtual_machine.dev01vm.admin_username
  description = "Admin name"
  sensitive   = true
}
