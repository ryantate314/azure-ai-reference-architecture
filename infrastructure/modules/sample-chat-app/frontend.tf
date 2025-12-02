module "frontend" {
  source = "Azure/avm-res-web-staticsite/azurerm"
  version = "0.6.2"

  name = "swa-${var.workload}-${var.environment}"
  location = var.location
  resource_group_name = azurerm_resource_group.main.name

  enable_telemetry = false
}