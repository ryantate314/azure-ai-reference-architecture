resource "random_string" "resource_token" {
  length = 6
  special = false
  upper = false
}

locals {
  default_foundry_name = "aif-${var.workload}-${var.environment}-${random_string.resource_token.result}"
  ai_foundry_name = var.resource_name != null ? var.resource_name : local.default_foundry_name
  use_managed_identity = var.managed_identity_id != null
}

resource "azurerm_cognitive_account" "ai_foundry" {
  name                = local.ai_foundry_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "AIServices"

  local_auth_enabled = false

  public_network_access_enabled = var.use_private_endpoints ? false : true

  identity {
    type = local.use_managed_identity ? "UserAssigned" : "SystemAssigned"
    identity_ids = local.use_managed_identity ? [var.managed_identity_id] : null
  }

  sku_name = var.ai_foundry_sku

  # required for stateful development in Foundry including agent service
  custom_subdomain_name = local.ai_foundry_name
  project_management_enabled = true

  tags = var.tags
}

resource "azurerm_cognitive_deployment" "deployment" {
  for_each = var.model_deployments

  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.ai_foundry.id

  sku {
    name     = each.value.sku_name
    capacity = each.value.sku_capacity
  }

  model {
    format  = each.value.format
    name    = each.value.name
    version = each.value.version
  }
}

resource "azurerm_private_endpoint" "ai_foundry" {
  count = var.use_private_endpoints ? 1 : 0

  name                = "pe-aif-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-aif-${var.workload}-${var.environment}"
    private_connection_resource_id = azurerm_cognitive_account.ai_foundry.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name = "dns-zone-group"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}