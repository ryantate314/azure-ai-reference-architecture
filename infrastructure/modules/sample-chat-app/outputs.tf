output "federated_identity_client_id" {
  description = "The client ID of the federated identity credential for GitHub Actions"
  value       = azurerm_user_assigned_identity.github.client_id
}