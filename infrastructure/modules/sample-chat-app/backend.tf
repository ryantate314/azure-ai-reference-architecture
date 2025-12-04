module "webapp_backend" {
  source = "Azure/avm-res-web-site/azurerm"
  version = "0.19.1"

  name                = "webapp-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  kind = "webapp"
  os_type = "Linux"
  # function_app_uses_fc1 = true
  # fc1_runtime_name = "python"
  # fc1_runtime_version = "3.12"
  service_plan_resource_id = azurerm_service_plan.backend.id

  # application_insights = {
  #   name = "appi-${var.workload}-${var.environment}"
  #   location = var.location
  #   resource_group_name = azurerm_resource_group.main.name
  # }

  # managed_identities = {
  #   user_assigned_resource_ids = [azurerm_user_assigned_identity.storage_identity.id]
  # }

  # storage_account_name = module.storage_account.name
  # storage_container_type = "blobContainer"
  # storage_container_endpoint = "https://${module.storage_account.name}.blob.core.windows.net/${module.storage_account.containers["blobContainer"].name}"

  # Key Based Access
  # storage_account_access_key = data.azurerm_storage_account.function_app.primary_access_key
  # storage_authentication_type = "StorageAccountConnectionString"

  # storage_uses_managed_identity = true
  # storage_authentication_type = "UserAssignedIdentity"
  # storage_user_assigned_identity_id = azurerm_user_assigned_identity.storage_identity.id

  enable_telemetry = false

  virtual_network_subnet_id = module.vnet_main.subnets["app_service_plan"].resource_id
  site_config = {
    vnet_route_all_enabled = true
  }
}

# resource "azurerm_app_service_virtual_network_swift_connection" "webapp_vnet_integration" {
#   app_service_id      = module.web_site.resource_id
#   subnet_id           = module.vnet_main.subnets["app_integration"].resource_id
# }

resource "azurerm_user_assigned_identity" "storage_identity" {
  name                = "id-st-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_role_assignment" "storage_account_access" {
  scope                = module.storage_account.resource_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.storage_identity.principal_id
}

resource "random_string" "storage_account" {
  length = 6
  special = false
  upper = false
}

module "storage_account" {
  source = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.7"

  name = "st${var.workload}${var.environment}${random_string.storage_account.result}"
  location = var.location
  resource_group_name = azurerm_resource_group.main.name
  account_tier = "Standard"
  account_replication_type = "LRS"

  # TODO: remove
  public_network_access_enabled = true
  shared_access_key_enabled = true

  
  
  # private_endpoints = {
  #   blob = {
  #     name = "pe-blob-${var.workload}-${var.environment}"
  #     subnet_resource_id = module.vnet_main.subnets["private_endpoints"].resource_id
  #     subresource_name = "blob"
  #     private_endpoints_manage_dns_zone_group = true
  #     private_dns_zone_resource_ids = [azurerm_private_dns_zone.blob.id]
  #   }
  # }

  enable_telemetry = false

  containers = {
    blobContainer = {
      name = "functionstorage"
      container_access_type = "private"
    }
  }
}

data "azurerm_storage_account" "function_app" {
  name               = module.storage_account.name
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_account_dns_link" {
  name                  = "link-${var.workload}-${var.environment}-blob-dns"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = module.vnet_main.resource_id
  registration_enabled  = false
}

resource "azurerm_role_assignment" "dev_storage_account" {
  scope                = module.storage_account.resource_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_group.devs.object_id
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
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
}