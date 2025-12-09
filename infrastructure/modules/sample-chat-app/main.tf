resource "azurerm_resource_group" "main" {
  name     = "rg-${var.workload}-${var.environment}"
  location = var.location
}

resource "azurerm_user_assigned_identity" "github" {
  name                = "uai-github-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_role_assignment" "github_website_contributor" {
  scope                = module.api.resource_id
  role_definition_name = "Website Contributor"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}

resource "azurerm_role_assignment" "github_acr_push" {
  scope                = module.api.resource_id
  role_definition_name = "Container Registry Repository Writer"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}

resource "azurerm_federated_identity_credential" "github_backend_webapp" {
  name                = "fic-github-webapp-${var.workload}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.github.id
  subject             = "repo:${var.repo_name}:ref:refs/heads/main"
}

resource "azurerm_container_registry" "main" {
  name                = "acr${var.workload}${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_user_assigned_identity" "backend_container" {
  name                = "uai-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.backend_container.principal_id
}

resource "azurerm_user_assigned_identity" "api" {
  name                = "uai-api-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_role_assignment" "ai_foundry_access" {
  scope                = module.ai_foundry.resource_id
  role_definition_name = "Cognitive Services User"
  principal_id         = azurerm_user_assigned_identity.api.principal_id
}

resource "azurerm_role_assignment" "api_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.api.principal_id
}

module "api" {
  source = "./modules/api"

  type = "containerservice"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  workload            = var.workload
  environment         = var.environment
  llm_endpoint = module.ai_foundry.endpoint_url
  app_service_plan_subnet_id = module.vnet_main.subnets["app_service_plan"].resource_id
  docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
  image_name = "${azurerm_container_registry.main.login_server}/sample-chat-app-api:latest"
  user_assigned_identity_id = azurerm_user_assigned_identity.api.id
  user_assigned_acr_identity_client_id = azurerm_user_assigned_identity.api.client_id
}

module "ai_foundry" {
  source = "./modules/ai-foundry"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  workload            = var.workload
  environment         = var.environment
  private_endpoint_subnet_id = module.vnet_main.subnets["private_endpoints"].resource_id

  model_deployments = {
    gpt_4o = {
      format = "OpenAI"
      name = "gpt-4o"
      version = "2024-08-06"
    }
  }

  tags                = var.tags
}