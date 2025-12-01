output "subnets" {
  description = "The subnets created in the shared infrastructure"
  value       = {
    bastion                 = module.vnet_hub.subnets["bastion"].resource_id
    jump_box                = module.vnet_hub.subnets["jump_box"].resource_id
  }
}

output "vnet_hub" {
  description = "The hub virtual network"
  value       =  {
    id = module.vnet_hub.resource_id
  }
}