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
  scope                = module.webapp_backend.resource_id
  role_definition_name = "Website Contributor"
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

module "ai_foundry" {
  source = "./modules/ai-foundry"

  location            = var.location
  resource_group_id = azurerm_resource_group.main.id
  workload            = var.workload
  environment         = var.environment
  tags                = var.tags
  private_endpoint_subnet_id = module.vnet_main.subnets["private_endpoints"].resource_id
}