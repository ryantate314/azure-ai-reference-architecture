resource "azurerm_virtual_network" "main" {
  name = "vnet-ai-foundry"
  location = var.location
  resource_group_name = var.resource_group_name
  address_space = [var.ip_ranges["virtual_network"]]
}

resource "azurerm_subnet" "app_service_integration" {
  name                 = "app-service-integration-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.ip_ranges["app_service_integration"]]
  default_outbound_access_enabled = false

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "private_endpoint" {
  name                 = "private-endpoint-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.ip_ranges["private_endpoint"]]
  default_outbound_access_enabled = false
  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_subnet" "bastion" {
  # Name must be exactly AzureBastionSubnet
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.ip_ranges["bastion"]]
  default_outbound_access_enabled = false
  private_endpoint_network_policies = "Disabled"
  private_link_service_network_policies_enabled = true
}

resource "azurerm_subnet" "jump_box" {
  name                 = "jump-box-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.ip_ranges["jump_box"]]
  default_outbound_access_enabled = false
  private_endpoint_network_policies = "Disabled"
  private_link_service_network_policies_enabled = true
}

# App Service Integration NSG and Rules
resource "azurerm_network_security_group" "app_service_integration" {
  name                = "nsg-app-service-integration"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "app_service_integration_nsg_association" {
  subnet_id                 = azurerm_subnet.app_service_integration.id
  network_security_group_id = azurerm_network_security_group.app_service_integration.id
}

resource "azurerm_network_security_rule" "app_service_integration_private_endpoints" {
    name = "AppPlan.Out.Allow.PrivateEndpoints"
    description = "Allow outbound traffic from the app service subnet to the private endpoints subnet"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443"
    source_address_prefix = var.ip_ranges["app_service_integration"]
    destination_address_prefix = var.ip_ranges["private_endpoint"]
    access = "Allow"
    priority = 100
    direction = "Outbound" 
    resource_group_name = var.resource_group_name
    network_security_group_name = azurerm_network_security_group.app_service_integration.name
}
resource "azurerm_network_security_rule" "app_service_integration_azure_monitor" {
    name = "AppPlan.Out.Allow.AzureMonitor"
    description = "Allow outbound traffic from App service to the AzureMonitor ServiceTag."
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = var.ip_ranges["app_service_integration"]
    destination_address_prefix = "AzureMonitor"
    access = "Allow"
    priority = 110
    direction = "Outbound"
    resource_group_name = var.resource_group_name
    network_security_group_name = azurerm_network_security_group.app_service_integration.name
}
