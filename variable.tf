# variables.tf
variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

variable "workspace_name" {
  description = "Name of the AVD workspace"
  type        = string
  default     = "my-avd-workspace"
}

variable "hostpool_name" {
  description = "Name of the AVD host pool"
  type        = string
  default     = "my-avd-hostpool"
}

variable "application_group_name" {
  description = "Name of the AVD application group"
  type        = string
  default     = "my-avd-app-group"
}

variable "session_host_count" {
  description = "Number of session host VMs to create"
  type        = number
  default     = 2
}

variable "session_host_size" {
  description = "Azure VM size for session hosts"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "Administrator username for session hosts"
  type        = string
}

variable "admin_password" {
  description = "Administrator password for session hosts"
  type        = string
  sensitive   = true
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "avd-vnet"
}

variable "subnet_name" {
  description = "Name of the subnet for session hosts"
  type        = string
  default     = "session-host-subnet"
}