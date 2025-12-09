output "resource_id" {
  description = "The resource ID of the AI Foundry cognitive account."
  value       = azurerm_cognitive_account.ai_foundry.id
}

output "system_assigned_identity_id" {
  description = "The principal ID of the system assigned identity for the AI Foundry cognitive account."
  value       = local.use_managed_identity ? null : azurerm_cognitive_account.ai_foundry.identity[0].principal_id
}

output "endpoint_url" {
  description = "The endpoint URL for the deployed AI model."
  value       = "https://${azurerm_cognitive_account.ai_foundry.name}.services.ai.azure.com/"
}

output "model_deployment_ids" {
  description = "A map of deployment names to their resource IDs."
  value = {
    for name, deployment in azurerm_cognitive_deployment.deployment :
    name => deployment.id
  }
}