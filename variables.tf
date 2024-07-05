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
}

variable "admin_username" {
  type        = string
  description = "Administrator user name"
  default     = "adminuser"
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

variable "tags" {
  type        = map(string)
  description = "Tags for resources"
  default = {
    "environment" = "DEV",
    "project"     = "NewDevHome"
    "team"        = "Software House"
  }
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
variable "tags" {
  type        = map(string)
  description = "Tags"
  default = {
    "Owner"        = "Epredator"
    "Organization" = "Etroya"
    "Environment"  = "Development"
  }
} 