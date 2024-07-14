# VARIABLES.TF 
variable "rg_name" {
  type        = string
  description = "Name of main resource group"
  default     = "App-VM-RG"
}

variable "location" {
  type        = string
  description = "Location of reosurces"
  default     = "East US"
}

variable "vnet_addressspace" {
  type        = string
  description = "Address sapace assigned to VNET"
  default     = "10.1.0.0/16"
}

variable "vm_name" {
  type        = string
  description = "Name of virtual machine"
  default     = "app01vm"
  sensitive   = true
  validation {
    condition     = !strcontains(lower(var.vm_name), "vm")
    error_message = "Initial name of the virtual machine cannot contain substring ‘vm’."
  }
}


variable "admin_username" {
  type        = string
  description = "Administrator user name"
  default     = "adminuser"
  validation {
    condition     = lower(var.admin_username) == var.admin_username
    error_message = "Admin user name can use only lowercase letters."
  }


}

variable "admin_password" {
  type        = string
  description = "Administrator’s password"
  default     = "TheAnswerIs42."
}

variable "subnets_addresses" {
  type        = list(string)
  description = "Addresses of subnets"
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "disk_names" {
  type        = list(string)
  description = "Names for disks"
  default     = ["disk_data", "disk_log"]
}

variable "disk_lunes" {
  type        = list(number)
  description = "Lun for disks"
  default     = [10, 11]
}

variable "disk_caches" {
  type        = list(string)
  description = "Cache setting for disks"
  default     = ["ReadWrite", "None"]
}

variable "disks" {
  type        = map(any)
  description = "Managed disks specifications"
  default = {
    disk_data = {
      lun   = "10",
      cache = "ReadWrite",
      size  = 1
    },
    disk_log = {
      lun   = "11",
      cache = "None",
      size  = 1
    }
  }
}


variable "tags" {
  type        = map(string)
  description = "Tags"
  default = {
    "project"      = "NewDevHome"
    "Owner"        = "Epredator"
    "Organization" = "Etroya"
    "Environment"  = "Development"
    "team"         = "Software House"
  }
}

variable "app_code" {
  type        = string
  description = "Application code"
  default     = "hr"
}

output "public_ip2" {
  value       = azurerm_public_ip.app01vm_pub_ip.ip_address
  description = "IP address of server"
}

output "nsg" {
  value       = azurerm_network_security_group.nsg_rdp.name
  description = "NSG name attached to the network interface"
  sensitive   = true
}

output "admin_username2" {
  value       = azurerm_windows_virtual_machine.app01vm.admin_username
  description = "Admin user name"
}

output "admin_password" {
  value       = azurerm_windows_virtual_machine.app01vm.admin_password
  description = "Admin password"
  sensitive   = true
}