# Main Terraform Configuration for Azure Virtual Desktop (AVD)

# Existing Resource Group
data "azurerm_resource_group" "avd_resource_group" {
  name     = var.resource_group_name
  //location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "avd_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = data.azurerm_resource_group.avd_resource_group.location
  resource_group_name = data.azurerm_resource_group.avd_resource_group.name
}

# Subnet
resource "azurerm_subnet" "avd_subnet" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.avd_resource_group.name
  virtual_network_name = azurerm_virtual_network.avd_vnet.name
  address_prefixes     = var.subnet_address_prefixes
}

# Network Security Group
resource "azurerm_network_security_group" "avd_nsg" {
  name                = var.nsg_name
  location            = data.azurerm_resource_group.avd_resource_group.location
  resource_group_name = data.azurerm_resource_group.avd_resource_group.name
}

# AVD Host Pool
resource "azurerm_virtual_desktop_host_pool" "avd_hostpool" {
  name                = var.hostpool_name
  location            = data.azurerm_resource_group.avd_resource_group.location
  resource_group_name = data.azurerm_resource_group.avd_resource_group.name

  type               = var.hostpool_type
  load_balancer_type = var.load_balancer_type
  
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registration_info" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.avd_hostpool.id
  expiration_date = timeadd(timestamp(), "48h")
}

# AVD Workspace
resource "azurerm_virtual_desktop_workspace" "avd_workspace" {
  name                = var.workspace_name
  location            = data.azurerm_resource_group.avd_resource_group.location
  resource_group_name = data.azurerm_resource_group.avd_resource_group.name
}

# Application Group
resource "azurerm_virtual_desktop_application_group" "avd_app_group" {
  name                = var.app_group_name
  location            = data.azurerm_resource_group.avd_resource_group.location
  resource_group_name = data.azurerm_resource_group.avd_resource_group.name
  
  type         = var.app_group_type
  host_pool_id = azurerm_virtual_desktop_host_pool.avd_hostpool.id
}

# Link Workspace and Application Group
resource "azurerm_virtual_desktop_workspace_application_group_association" "workspace_app_group_assoc" {
  workspace_id         = azurerm_virtual_desktop_workspace.avd_workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.avd_app_group.id
}

# Public IP for VM
resource "azurerm_public_ip" "avd_vm_ip" {
  name                = var.vm_public_ip_name
  location            = data.azurerm_resource_group.avd_resource_group.location
  resource_group_name = data.azurerm_resource_group.avd_resource_group.name
  allocation_method   = "Dynamic"
}

# Network Interface
resource "azurerm_network_interface" "avd_vm_nic" {
  name                = var.vm_nic_name
  location            = data.azurerm_resource_group.avd_resource_group.location
  resource_group_name = data.azurerm_resource_group.avd_resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.avd_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.avd_vm_ip.id
  }
}

# Windows VM for AVD
resource "azurerm_windows_virtual_machine" "avd_vm" {
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.avd_resource_group.name
  location            = data.azurerm_resource_group.avd_resource_group.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.avd_vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-evd"
    version   = "latest"
  }
}

# Register VM to Host Pool (requires custom script extension)

resource "azurerm_virtual_machine_extension" "avd_vm_register" {
  name                 = "avd-vm-registration"
  virtual_machine_id   = azurerm_windows_virtual_machine.avd_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell.exe -Command \"& {$registrationToken = '${azurerm_virtual_desktop_host_pool_registration_info.registration_info.token}'; Add-LocalGroupMember -Group 'Remote Desktop Users' -Member 'BUILTIN\\Users'}\""
    }
  SETTINGS

  depends_on = [
    azurerm_windows_virtual_machine.avd_vm,
    azurerm_virtual_desktop_host_pool_registration_info.registration_info
  ]
}



/*resource "azurerm_virtual_machine_extension" "avd_vm_register" {
  name                 = "avd-vm-registration"
  virtual_machine_id   = azurerm_windows_virtual_machine.avd_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell.exe -Command \"& {$registrationToken = '${azurerm_virtual_desktop_host_pool.avd_hostpool.registration_info[0].token}'; Add-LocalGroupMember -Group 'Remote Desktop Users' -Member 'BUILTIN\\Users'}\""
    }
  SETTINGS

  depends_on = [azurerm_windows_virtual_machine.avd_vm]
}
*/

# Example Application (placeholder - customize as needed)
resource "azurerm_virtual_desktop_application" "example_app" {
  name                         = var.example_app_name
  application_group_id         = azurerm_virtual_desktop_application_group.avd_app_group.id
  friendly_name                = var.example_app_friendly_name
  description                  = var.example_app_description
  path                         = var.example_app_path
  command_line_argument_policy = "DoNotAllow"
  show_in_portal               = true
}

# Log Analytics Workspace for Diagnostics
resource "azurerm_log_analytics_workspace" "avd_workspace" {
  name                = var.log_analytics_workspace_name
  location            = data.azurerm_resource_group.avd_resource_group.location
  resource_group_name = data.azurerm_resource_group.avd_resource_group.name
  sku                 = "PerGB2018"
}

/*# Optional: Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "avd_diagnostics" {
  name                       = "avd-diagnostics"
  target_resource_id         = azurerm_virtual_desktop_host_pool.avd_hostpool.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.avd_workspace.id

  log {
    category = "Checkpoint"
    enabled  = true
  }

  log {
    category = "Error"
    enabled  = true
  }
} */

resource "random_uuid" "role_assignment_name" {}

# User/Group Assignment (example)
resource "azurerm_role_assignment" "app_group_assignment" {
  name                 = random_uuid.role_assignment_name.result
  scope                = azurerm_virtual_desktop_application_group.avd_app_group.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = var.azure_ad_principal_id
}