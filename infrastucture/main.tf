resource "azurerm_resource_group" "shared" {
  name = "ai-foundry-reference-architecture"
  location = var.location
}

resource "random_password" "bastion_password" {
  length           = 16
  special          = true
}

module "shared_infrastructure" {
  source = "./modules/shared-infrastructure"

  resource_group_name = azurerm_resource_group.shared.name
  resource_group_id = azurerm_resource_group.shared.id

  location            = var.location
  ip_ranges           = {
    virtual_network          = "10.0.0.0/16"
    bastion                 = "10.0.3.0/24"
    jump_box                = "10.0.4.0/24"
  }
  subscription_id = var.subscription_id
  bastion_password = random_password.bastion_password.result
  deploy_bastion = false
}

module "sample_chat_app" {
  source = "./modules/sample-chat-app"

  workload     = "samplechatapp"
  environment  = "dev"
  location     = var.location
  ip_ranges    = {
    virtual_network      = "10.1.0.0/16"
    private_endpoints    = "10.1.0.0/24"
    app_service_plan = "10.1.1.0/24"
  }
  hub_vnet_id = module.shared_infrastructure.vnet_hub.id
}