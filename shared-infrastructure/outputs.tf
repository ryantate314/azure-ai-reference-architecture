output "subnets" {
  description = "The subnets created in the shared infrastructure"
  value       = {
    app_service_integration = azurerm_subnet.app_service_integration.id
    private_endpoint        = azurerm_subnet.private_endpoint.id
    bastion                 = azurerm_subnet.bastion.id
    jump_box                = azurerm_subnet.jump_box.id
  }
}