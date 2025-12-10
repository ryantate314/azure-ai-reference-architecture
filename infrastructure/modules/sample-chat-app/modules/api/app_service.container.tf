resource "azurerm_linux_web_app" "backend_container" {
  count = var.type == "containerservice" ? 1 : 0

  name                = "webapp-${var.workload}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.backend_container[0].id
  vnet_image_pull_enabled = true

  site_config {
    always_on = false
    vnet_route_all_enabled = true

    container_registry_use_managed_identity = true
    container_registry_managed_identity_client_id = var.user_assigned_acr_identity_client_id

    application_stack {
      docker_image_name = var.image_name
      docker_registry_url = var.docker_registry_url
    }
  }

  identity {
    type         = var.user_assigned_identity_id != null ? "UserAssigned" : "SystemAssigned"
    identity_ids = var.user_assigned_identity_id != null ? [var.user_assigned_identity_id] : []
  }

  app_settings = {
    LLM_ENDPOINT = var.llm_endpoint
  }
}


resource "random_string" "storage_account_container" {
  count = var.type == "containerservice" ? 1 : 0

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

resource "azurerm_service_plan" "backend_container" {
  count = var.type == "containerservice" ? 1 : 0

  name                = "plan-${var.workload}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
}