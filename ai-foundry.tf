resource "random_string" "storage_account_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "ai_foundry" {
  name = "saaifoundry${random_string.storage_account_suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  account_tier        = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_private_endpoint" "ai_foundry_pe" {
  name                = "ai-foundry-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.shared_infrastructure.subnets.private_endpoint

  private_service_connection {
    name                           = "ai-foundry-psc"
    private_connection_resource_id = azapi_resource.ai_foundry.id
    is_manual_connection           = false
    subresource_names = ["account"]
  }
}

resource "azurerm_key_vault" "ai_foundry" {
  name = "kv-aifoundry-${random_string.storage_account_suffix.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name = "standard"
  purge_protection_enabled = true
}

resource "azapi_resource" "ai_foundry" {
  location  = var.location
  name      = "ai-foundry-${random_string.storage_account_suffix.result}"
  parent_id = azurerm_resource_group.main.id
  type      = "Microsoft.CognitiveServices/accounts@2025-04-01-preview"
  body = {

    kind = "AIServices",
    sku = {
      name = "S0"
    }
    identity = {
      type = "SystemAssigned"
    }

    properties = {
      disableLocalAuth       = true
      allowProjectManagement = true
      # The subdomain is sticky and will throw conflicts if dropped and re-created quickly
      customSubDomainName    = "ai-foundry-${random_string.storage_account_suffix.result}"
      publicNetworkAccess    = "Enabled"
      networkAcls = {
        defaultAction       = "Allow"
        virtualNetworkRules = []
        ipRules             = []
      }

      # Enable VNet injection for Standard Agents
      networkInjections = null
    }
  }
  schema_validation_enabled = false
}

# Creates an AI Foundry Hub
# resource "azurerm_ai_foundry" "main" {
#   name                = "ai-foundry-instance"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.main.name
#   storage_account_id = azurerm_storage_account.ai_foundry.id
#   key_vault_id = azurerm_key_vault.ai_foundry.id

#   identity {
#     type = "SystemAssigned"
#   }
# }

resource "azapi_resource" "ai_foundry_project" {
  location  = var.location
  name      = "example-project"
  parent_id = azapi_resource.ai_foundry.id
  type      = "Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview"
  body = {
    sku = {
      name = "S0"
    }
    identity = {
      type = "SystemAssigned"
    }
    properties = {
      displayName = "Example Project"
      description = "This is an example project."
    }
  }
  response_export_values = [
    "identity.principalId",
    "properties.internalId"
  ]
  schema_validation_enabled = false
}