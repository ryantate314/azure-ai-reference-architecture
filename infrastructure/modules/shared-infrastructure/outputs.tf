output "subnets" {
  description = "The subnets created in the shared infrastructure"
  value       = {
    bastion                 = azurerm_subnet.bastion.id
    jump_box                = azurerm_subnet.jump_box.id
  }
}

output "vnet_hub" {
  description = "The hub virtual network"
  value       =  {
    id = azurerm_virtual_network.vnet_hub.id
  }
}