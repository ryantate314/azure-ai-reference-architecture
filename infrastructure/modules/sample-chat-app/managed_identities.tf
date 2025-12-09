# Github Federated Credential

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
  scope                = azurerm_container_registry.main.id
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

# Backend API User Assigned Identity
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