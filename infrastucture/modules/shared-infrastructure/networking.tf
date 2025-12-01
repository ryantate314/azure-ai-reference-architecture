module "vnet_hub" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.16.0"

  name = "vnet-hub"

  location = var.location
  parent_id = var.resource_group_id
  address_space = [var.ip_ranges["virtual_network"]]

  subnets = {
    bastion = {
      name = "snet-bastion"
      address_prefixes = [var.ip_ranges["bastion"]]
      private_endpoint_network_policies = "Disabled"
      private_link_service_network_policies_enabled = true
      default_outbound_access_enabled = false
    }
    jump_box = {
      name = "snet-jumpbox"
      address_prefixes = [var.ip_ranges["jump_box"]]
      private_endpoint_network_policies = "Disabled"
      private_link_service_network_policies_enabled = true
      default_outbound_access_enabled = false # Force agent traffic through your firewall
    }
  }
}

# Bastion
resource "azurerm_network_security_group" "bastion" {
  name                = "nsg-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "bastion_nsg_association" {
  subnet_id                 = module.vnet_hub.subnets["bastion"].resource_id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

resource "azurerm_network_security_rule" "bastion_allow_https_inbound" {
  name = "Bastion.In.Allow.Https"
  description = "Allow inbound HTTPS traffic from the internet to the Bastion Host"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "443"
  source_address_prefix = "Internet"
  destination_address_prefix = "*"
  access = "Allow"
  priority = 100
  direction = "Inbound" 
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion.name
}

resource "azurerm_network_security_rule" "bastion_allow_gateway_manager_inbound" {
  name = "Bastion.In.Allow.GatewayManager"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_ranges = [
    "443",
    "4443"
  ]
  source_address_prefix = "GatewayManager"
  destination_address_prefix = "*"
  access = "Allow"
  priority = 110
  direction = "Inbound" 
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion.name
}

resource "azurerm_network_security_rule" "bastion_allow_load_balancer_inbound" {
  name = "Bastion.In.Allow.LoadBalancer"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "443"
  source_address_prefix = "AzureLoadBalancer"
  destination_address_prefix = "*"
  access = "Allow"
  priority = 120
  direction = "Inbound" 
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion.name
}

resource "azurerm_network_security_rule" "bastion_allow_bastion_host_inbound" {
  name = "Bastion.In.Allow.BastionHostCommunication"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_ranges = [
    "8080",
    "5701"
  ]
  source_address_prefix = "VirtualNetwork"
  destination_address_prefix = "VirtualNetwork"
  access = "Allow"
  priority = 130
  direction = "Inbound" 
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion.name
}

resource "azurerm_network_security_rule" "bastion_deny_inbound" {
  name = "DenyAllInbound"
  protocol = "*"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  access = "Deny"
  priority = 1000
  direction = "Inbound" 
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion.name
}

resource "azurerm_network_security_rule" "bastion_allow_ssh_rdp_outbound" {
  name = "Bastion.Out.Allow.SshRdp"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_ranges = [
    "22",
    "3389"
  ]
  source_address_prefix = "*"
  destination_address_prefix = "VirtualNetwork"
  access = "Allow"
  priority = 100
  direction = "Outbound" 
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion.name
}

resource "azurerm_network_security_rule" "bastion_allow_azure_monitor_outbound" {
  name = "Bastion.Out.Allow.AzureMonitor"
  description = "Allow outbound traffic from the Bastion Host subnet to Azure Monitor"
  protocol = "*"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefix = var.ip_ranges["bastion"]
  destination_address_prefix = "AzureMonitor"
  access = "Allow"
  priority = 110
  direction = "Outbound" 
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion.name
}

resource "azurerm_network_security_rule" "bastion_allow_azure_cloud_outbound" {
  name = "Bastion.Out.Allow.AzureCloudCommunication"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "443"
  source_address_prefix = "*"
  destination_address_prefix = "AzureCloud"
  access = "Allow"
  priority = 120
  direction = "Outbound" 
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion.name
}

resource "azurerm_network_security_rule" "bastion_allow_bastion_host_outbound" {
  name = "Bastion.Out.Allow.BastionHostCommunication"
  protocol = "*"
  source_port_range = "*"
  destination_port_ranges = [
    "8080",
    "5701"
  ]
  source_address_prefix = "VirtualNetwork"
  destination_address_prefix = "VirtualNetwork"
  access = "Allow"
  priority = 130
  direction = "Outbound" 
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion.name
}

resource "azurerm_network_security_rule" "bastion_allow_get_session_information_outbound" {
  name = "Bastion.Out.Allow.GetSessionInformation"
  protocol = "*"
  source_port_range = "*"
  destination_port_ranges = [
    "80",
    "443"
  ]
  source_address_prefix = "*"
  destination_address_prefix = "Internet"
  access = "Allow"
  priority = 140
  direction = "Outbound" 
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion.name
}

resource "azurerm_network_security_rule" "bastion_deny_outbound" {
  name = "DenyAllOutBound"
  protocol = "*"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  access = "Deny"
  priority = 1000
  direction = "Outbound" 
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion.name
}
