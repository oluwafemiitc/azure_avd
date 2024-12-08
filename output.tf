# Outputs for Azure Virtual Desktop (AVD) Deployment

output "resource_group_name" {
  description = "Name of the resource group"
  value       = data.azurerm_resource_group.avd_resource_group.name
}

output "host_pool_name" {
  description = "Name of the AVD host pool"
  value       = azurerm_virtual_desktop_host_pool.avd_hostpool.name
}

output "workspace_name" {
  description = "Name of the AVD workspace"
  value       = azurerm_virtual_desktop_workspace.avd_workspace.name
}

//output "application