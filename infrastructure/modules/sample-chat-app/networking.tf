module "vnet_main" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.16.0"

  name = "vnet-${var.workload}-${var.environment}"

  location = var.location
  parent_id = azurerm_resource_group.main.id
  address_space = [var.ip_ranges["virtual_network"]]
  enable_telemetry = false

  subnets = {
    private_endpoints = {
      name = "snet-privateendpoints"
      address_prefixes = [var.ip_ranges["private_endpoints"]]
      private_endpoint_network_policies = "Enabled"
      private_link_service_network_policies_enabled = true
      default_outbound_access_enabled = false
    }
    app_service_plan = {
      name = "snet-appserviceplan"
      address_prefixes = [var.ip_ranges["app_service_plan"]]
      default_outbound_access_enabled = false
      delegations = [{
        name = "delegation"
        service_delegation = {
          name = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }]
    }
    ai_agents = {
      name = "snet-agentsEgress"
      address_prefixes = [var.ip_ranges["agents_egress"]]
      default_outbound_access_enabled = false
      private_endpoint_network_policies = "Disabled"
      private_link_service_network_policies_enabled = false
    }
    # app_integration = {
    #   name = "snet-appintegration"
    #   address_prefixes = [var.ip_ranges["app_integration"]]
    #   default_outbound_access_enabled = false
    #   delegations = [{
    #     name = "delegation"
    #     service_delegation = {
    #       name = "Microsoft.App/environments"
    #     }
    #   }]
    # }
  }

  peerings = {
    "${var.workload}_to_hub" = {
      name = "peer-${var.workload}-to-hub"
      remote_virtual_network_resource_id = var.hub_vnet_id
    }
  }
}

# Private Endpoints Subnet Network Security Group
resource "azurerm_network_security_group" "private_endpoints" {
  name                = "nsg-privateendpoints"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "private_endpoints_deny_outbound" {
  name                        = "DenyAllOutBound"
  description                 = "Deny outbound traffic from the private endpoints subnet"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.ip_ranges["private_endpoints"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.private_endpoints.name
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints_nsg_association" {
  subnet_id                 = module.vnet_main.subnets["private_endpoints"].resource_id
  network_security_group_id = azurerm_network_security_group.private_endpoints.id
}

# App Service Plan Network Security Group
resource "azurerm_network_security_group" "app_service_plan" {
  name                = "nsg-appserviceplan"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "app_service_plan_allow_private_endpoints_outbound" {
  name                        = "AppPlan.Out.Allow.PrivateEndpoints"
  description                 = "Allow outbound traffic from the app service subnet to the private endpoints subnet"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = var.ip_ranges["app_service_plan"]
  destination_address_prefix  = var.ip_ranges["private_endpoints"]
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.app_service_plan.name
}

resource "azurerm_network_security_rule" "app_service_plan_allow_azure_monitor_outbound" {
  name                        = "AppPlan.Out.Allow.AzureMonitor"
  description                 = "Allow outbound traffic from App service to the AzureMonitor ServiceTag."
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.ip_ranges["app_service_plan"]
  destination_address_prefix  = "AzureMonitor"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.app_service_plan.name
}

resource "azurerm_subnet_network_security_group_association" "app_service_plan_nsg_association" {
  subnet_id                 = module.vnet_main.subnets["app_service_plan"].resource_id
  network_security_group_id = azurerm_network_security_group.app_service_plan.id
}

# AI Agents Egress Subnet Network Security Group
resource "azurerm_network_security_group" "ai_agents" {
  name                = "nsg-agentsEgress"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "ai_agents_deny_inbound" {
  name                        = "DenyAllInBound"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.ai_agents.name
}

resource "azurerm_network_security_rule" "ai_agents_allow_private_endpoints_outbound" {
  name                        = "Agents.Out.Allow.PrivateEndpoints"
  description                 = "Allow outbound traffic from the Foundry Agent egress subnet to the Private Endpoints subnet."
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.ip_ranges["agents_egress"]
  destination_address_prefix  = var.ip_ranges["private_endpoints"]
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.ai_agents.name
}

resource "azurerm_network_security_rule" "ai_agents_allow_internet_outbound" {
  name                        = "Agents.Out.AllowTcp443.Internet"
  description                 = "Allow outbound traffic from the Foundry Agent egress subnet to Internet on 443 (Azure firewall to filter further)"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = var.ip_ranges["agents_egress"]
  destination_address_prefix  = "Internet"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.ai_agents.name
}

resource "azurerm_network_security_rule" "ai_agents_deny_outbound" {
  name                        = "DenyAllOutBound"
  description                 = "Deny all other outbound traffic from the Foundry Agent Service subnet."
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.ip_ranges["agents_egress"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.ai_agents.name
}

resource "azurerm_subnet_network_security_group_association" "ai_agents_nsg_association" {
  subnet_id                 = module.vnet_main.subnets["ai_agents"].resource_id
  network_security_group_id = azurerm_network_security_group.ai_agents.id
}

# Private DNS Zones
resource "azurerm_private_dns_zone" "cognitiveservices" {
  name                = "privatelink.cognitiveservices.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "cognitiveservices_link" {
  name                  = "link-cognitiveservices-${var.workload}-${var.environment}"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.cognitiveservices.name
  virtual_network_id    = module.vnet_main.resource_id
  registration_enabled  = false
}