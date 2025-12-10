resource "azurerm_resource_group" "main" {
  name     = "rg-${var.workload}-${var.environment}"
  location = var.location
}


resource "azurerm_container_registry" "main" {
  name                = "acr${var.workload}${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Basic"
  admin_enabled       = false
}


module "api" {
  source = "./modules/api"

  type = "containerservice"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  workload            = var.workload
  environment         = var.environment
  llm_endpoint = module.ai_foundry.cognitiveservices_endpoint_url
  app_service_plan_subnet_id = module.vnet_main.subnets["app_service_plan"].resource_id
  docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
  image_name = "sample-chat-app-api:latest"
  user_assigned_identity_id = azurerm_user_assigned_identity.api.id
  user_assigned_acr_identity_client_id = azurerm_user_assigned_identity.api.client_id
}

module "ai_foundry" {
  source = "./modules/ai-foundry"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  workload            = var.workload
  environment         = var.environment

  use_private_endpoints = true
  private_endpoint_subnet_id = module.vnet_main.subnets["private_endpoints"].resource_id
  private_dns_zone_ids = [azurerm_private_dns_zone.cognitiveservices.id]

  model_deployments = {
    gpt_4o = {
      format = "OpenAI"
      name = "gpt-4o"
      version = "2024-08-06"
    }
  }

  tags                = var.tags
}