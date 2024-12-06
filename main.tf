# main.tf
# Data source to fetch existing resource group
data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group_name
}

# Virtual Desktop Workspace
resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = var.workspace_name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location
}

# Host Pool Configuration
resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  name                = var.hostpool_name
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name

  type               = "Pooled"
  load_balancer_type = "BreadthFirst"

  start_vm_on_connect     = true
  maximum_sessions_allowed = 3
}

# Application Group
resource "azurerm_virtual_desktop_application_group" "desktop" {
  name                = var.application_group_name
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name

  type         = "Desktop"
  host_pool_id = azurerm_virtual_desktop_host_pool.hostpool.id
}

# Workspace and Application Group Association
resource "azurerm_virtual_desktop_workspace_application_group_association" "workspace_app_group" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop.id
}

# Network Interface for Session Hosts
resource "azurerm_network_interface" "session_host_nic" {
  count               = var.session_host_count
  name                = "avd-session-host-nic-${count.index + 1}"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.session_host_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Session Host Virtual Machines
resource "azurerm_windows_virtual_machine" "session_host" {
  count               = var.session_host_count
  name                = "avd-ses-host-${count.index + 1}"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location
  size                = var.session_host_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.session_host_nic[count.index].id
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

# Virtual Network
resource "azurerm_virtual_network" "avd_vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

# Subnet for Session Hosts
resource "azurerm_subnet" "session_host_subnet" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
  virtual_network_name = azurerm_virtual_network.avd_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}