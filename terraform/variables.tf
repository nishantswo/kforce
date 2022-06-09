variable "subscriptionid" {
    description = "subscription_id"
    default = "c64a075f-4b0e-47b9-84cd-4b3d33bb01e5"
}

variable "clientid" {
    description = "client_id"
    default = "0fd134b1-c910-439d-9583-1a406807ca37"
}

variable "clientsecret" {
    description = "client_secret"
    default = "oj38Q~WtblyM0fLof1pQwL2wOBufsOhFz23HlcdS"
}

variable "tenantid" {
    description = "tenant_id"
    default = "5fbe543d-f826-49d2-8044-4f6edc87115c"
}

variable "node_count" {
default = "2"
} 

variable "resource_group_name" {
  description = "Default resource group name that the existing resources are in"
  default     = "devops-interview-gauntlet-x-mkhan"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  default     = "eastus"
}

variable "vnet_name1" {
  description = "Name of the Vnet"
  default     = "kforce-vnet"
}


variable "vnet_add1" {
  description = "Address prefix for Vnet"
  default     = "10.25.0.0/16"
}

variable "subnet1" {
  description = "Name of the Subnet"
  default     = "kforce-web-subnet"
}

variable "subnet2" {
  description = "Name of the Subnet"
  default     = "kforce-app-subnet"
}

variable "sub1_add" {
  description = "Address prefix for subnet"
  default     = "10.25.1.0/26"
}

variable "sub2_add" {
  description = "Address prefix for subnet"
  default     = "10.25.2.0/26"
}

variable "nsg_name1" {
  description = "The NSG name to be associated with the VM"
  default     = "kforce-web-subnet-nsg"
}

variable "diag_account" {
  description = "Name of the diagnostics storage acc"
  default     = "kforcediag"
}

variable vm_name {
  description = "Name of the VM"
  default     = "kforce-VM"
}

variable vm_size {
  description = "size of the VM"
  default     = "Standard_A2"
}

variable "lb" {
  description = "Name of the Load Balancer"
  default     = "kforce-LB"
}