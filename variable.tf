# Variables for Azure Virtual Desktop (AVD) Deployment

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  //default     = "rg-aztraining-cat-uk"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-avd"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "subnet-avd"
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
  default     = "nsg-avd"
}

variable "hostpool_name" {
  description = "Name of the AVD host pool"
  type        = string
  default     = "hostpool-avd-01"
}

variable "hostpool_type" {
  description = "Type of host pool"
  type        = string
  default     = "Pooled"
}

variable "load_balancer_type" {
  description = "Load balancer type for the host pool"
  type        = string
  default     = "BreadthFirst"
}

variable "workspace_name" {
  description = "Name of the AVD workspace"
  type        = string
  default     = "workspace-avd-01"
}

variable "app_group_name" {
  description = "Name of the application group"
  type        = string
  default     = "appgroup-avd-01"
}

variable "app_group_type" {
  description = "Type of application group"
  type        = string
  default     = "RemoteApp"
}

variable "vm_public_ip_name" {
  description = "Name of the public IP for the VM"
  type        = string
  default     = "pip-avd-vm"
}

variable "vm_nic_name" {
  description = "Name of the network interface for the VM"
  type        = string
  default     = "nic-avd-vm"
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "vm-avd-01"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "example_app_name" {
  description = "Name of the example application"
  type        = string
  default     = "example-application"
}

variable "example_app_friendly_name" {
  description = "Friendly name of the example application"
  type        = string
  default     = "Example App"
}

variable "example_app_description" {
  description = "Description of the example application"
  type        = string
  default     = "Sample application for AVD"
}

variable "example_app_path" {
  description = "Path to the example application"
  type        = string
  default     = "C:\\Windows\\System32\\notepad.exe"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
  default     = "law-avd-diagnostics"
}

variable "azure_ad_principal_id" {
  description = "Azure AD User or Group Object ID for role assignment"
  type        = string
}