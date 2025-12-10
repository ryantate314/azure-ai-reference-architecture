# Outputs for app service or container app deployments
output "resource_id" {
  description = "The resource ID of the API backend"
  value       = var.type == "containerservice" ? azurerm_linux_web_app.backend_container[0].id : module.webapp_backend[0].resource_id
}

output "resource_uri" {
  description = "The URI of the API backend"
  value       = var.type == "containerservice" ? azurerm_linux_web_app.backend_container[0].default_hostname : module.webapp_backend[0].resource_uri
}

output "system_assigned_identity_id" {
  description = "The system assigned identity ID of the API backend"
  value       = var.type == "containerservice" ? azurerm_linux_web_app.backend_container[0].identity[0].principal_id : module.webapp_backend[0].system_assigned_identity_id
}