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