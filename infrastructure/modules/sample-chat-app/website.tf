module "web_site" {
  source = "Azure/avm-res-web-site/azurerm"
  version = "0.19.1"

  name                = "webapp-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  kind = "functionapp"
  os_type = "Linux"
  service_plan_resource_id = module.server_farm.resource_id

  # application_insights = {
  #   name = "appi-${var.workload}-${var.environment}"
  #   location = var.location
  #   resource_group_name = azurerm_resource_group.main.name
  # }

  storage_account_name = module.storage_account.name

  enable_telemetry = false
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

  enable_telemetry = false
}

module "server_farm" {
  source = "Azure/avm-res-web-serverfarm/azurerm"
  version = "1.0.0"

  name                = "plan-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  os_type = "Linux"

  sku_name = "B1"
  zone_balancing_enabled = false

  enable_telemetry = false
}