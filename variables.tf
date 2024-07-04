# VARIABLES.TF 
variable "rg_name" { 
type = string 
description = "Name of main resource group" 
default = "App-VM-RG"
} 
 
variable "location" { 
type = string 
description = "Location of reosurces"
default = "East US"
} 
 
variable "vnet_addressspace" { 
type = string 
description = "Address sapace assigned to VNET"
default = "10.1.0.0/16"
} 
 
variable "vm_name" { 
type = string 
description = "Name of virtual machine"
default = "app01vm"
} 
 
variable "admin_username" { 
type = string 
description = "Administrator user name"
default = "adminuser"
} 
 
variable "admin_password" { 
type = string 
description = "Administrator’s password"
default = "TheAnswerIs42."
} 
    
variable "subnets_addresses" { 
type = list(string) 
description = "Addresses of subnets"
default     = ["10.1.1.0/24", "10.1.2.0/24"] 
} 
        
variable "tags" { 
type = map(string) 
description = "Tags for resources"
default = { 
"environment" = "DEV", 
"project" = "NewDevHome"
"team" = "Software House"
} 
} 