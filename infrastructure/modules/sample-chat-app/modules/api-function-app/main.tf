# User-assigned managed identity for the function app
resource "azurerm_user_assigned_identity" "function_app" {
  name                = "id-func-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Storage account for function app
resource "random_string" "storage_account" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_account" "function_app" {
  name                     = "stfunc${var.workload}${var.environment}${random_string.storage_account.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  # Disable public access
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_storage_container" "function_app" {
  name                  = "function-releases"
  storage_account_name  = azurerm_storage_account.function_app.name
  container_access_type = "private"
}

# Private endpoint for storage account blob
resource "azurerm_private_endpoint" "storage_blob" {
  name                = "pe-blob-func-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "psc-blob-func-${var.workload}-${var.environment}"
    private_connection_resource_id = azurerm_storage_account.function_app.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "pdz-group-blob"
    private_dns_zone_ids = [var.blob_private_dns_zone_id]
  }
}



# Role assignment for managed identity to access storage
resource "azurerm_role_assignment" "storage_blob_data_owner" {
  scope                = azurerm_storage_account.function_app.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.function_app.principal_id
}

resource "azurerm_role_assignment" "storage_account_contributor" {
  scope                = azurerm_storage_account.function_app.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.function_app.principal_id
}



# App Service Plan for Function App
resource "azurerm_service_plan" "function_app" {
  name                = "plan-func-${var.workload}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "S1"
}

# Linux Function App
resource "azurerm_linux_function_app" "main" {
  name                = "func-${var.workload}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  service_plan_id            = azurerm_service_plan.function_app.id
  storage_account_name       = azurerm_storage_account.function_app.name
  virtual_network_subnet_id  = var.app_service_plan_subnet_id
  
  # Use managed identity for storage authentication
  storage_uses_managed_identity = true

  # Disable public access
  public_network_access_enabled = false
  https_only                   = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.function_app.id]
  }

  site_config {
    vnet_route_all_enabled = true
    
    application_stack {
      python_version = "3.11"
    }

    # Disable basic auth
    ftps_state = "Disabled"
  }

  app_settings = {
    "AzureWebJobsStorage__accountName" = azurerm_storage_account.function_app.name
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = ""
    "WEBSITE_CONTENTSHARE" = ""
    "WEBSITE_CONTENTOVERVNET" = "1"
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "ENABLE_ORYX_BUILD" = "true"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
  }

  depends_on = [
    azurerm_private_endpoint.storage_blob,
    azurerm_role_assignment.storage_blob_data_owner,
    azurerm_role_assignment.storage_account_contributor
  ]
}


