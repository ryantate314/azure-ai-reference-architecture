resource "azurerm_resource_group" "main" {
  name = "ai-foundry-reference-architecture"
  location = var.location
}

resource "random_password" "bastion_password" {
  length           = 16
  special          = true
}

module "shared_infrastructure" {
  source = "./shared-infrastructure"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  ip_ranges           = {
    virtual_network          = "10.0.0.0/16"
    app_service_integration  = "10.0.1.0/24"
    private_endpoint         = "10.0.2.0/24"
    bastion                 = "10.0.3.0/24"
    jump_box                = "10.0.4.0/24"
  }
  subscription_id = var.subscription_id
  bastion_password = random_password.bastion_password.result
  deploy_bastion = false
}