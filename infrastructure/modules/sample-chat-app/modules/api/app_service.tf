module "webapp_backend" {
  count = var.type == "appservice" ? 1 : 0

  source = "Azure/avm-res-web-site/azurerm"
  version = "0.19.1"

  name                = "webapp-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind = "webapp"
  os_type = "Linux"
  service_plan_resource_id = azurerm_service_plan.backend.id
  virtual_network_subnet_id = var.app_service_plan_subnet_id

  webdeploy_publish_basic_authentication_enabled = false
  scm_publish_basic_authentication_enabled = false
  ftp_publish_basic_authentication_enabled = false

  managed_identities = {
    user_assigned_resource_ids = [azurerm_user_assigned_identity.backend.id]
  }


  enable_telemetry = false

  site_config = {
    vnet_route_all_enabled = true
    application_stack = {
    }
  }

  app_settings = {
    LLM_ENDPOINT = var.llm_endpoint
  }
}

resource "azurerm_user_assigned_identity" "backend" {
  name                = "id-st-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "random_string" "storage_account" {
  length = 6
  special = false
  upper = false
}

# module "server_farm" {
#   source = "Azure/avm-res-web-serverfarm/azurerm"
#   version = "1.0.0"

#   name                = "plan-${var.workload}-${var.environment}"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.main.name
#   os_type = "Linux"

#   sku_name = "FC1"
#   zone_balancing_enabled = false

#   enable_telemetry = false
# }

resource "azurerm_service_plan" "backend" {
  name                = "plan-${var.workload}-${var.environment}-2"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
}