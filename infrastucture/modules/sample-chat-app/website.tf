module "web_site" {
  source = "Azure/avm-res-web-site/azurerm"
  version = "0.19.1"

  name                = "webapp-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  kind = "functionapp"
  os_type = "linux"
  service_plan_resource_id = module.server_farm.resource_id

  application_insights = {
    name = "appi-${var.workload}-${var.environment}"
    location = var.location
    resource_group_name = azurerm_resource_group.main.name
  }
}

module "server_farm" {
  source = "Azure/avm-res-web-serverfarm/azurerm"
  version = "1.0.0"

  name                = "plan-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  os_type = "linux"
}