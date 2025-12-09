output "function_app_id" {
  description = "The ID of the function app"
  value       = azurerm_linux_function_app.main.id
}

output "function_app_name" {
  description = "The name of the function app"
  value       = azurerm_linux_function_app.main.name
}

output "function_app_default_hostname" {
  description = "The default hostname of the function app"
  value       = azurerm_linux_function_app.main.default_hostname
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.function_app.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.function_app.name
}

output "function_app_identity_principal_id" {
  description = "The principal ID of the function app managed identity"
  value       = azurerm_user_assigned_identity.function_app.principal_id
}
