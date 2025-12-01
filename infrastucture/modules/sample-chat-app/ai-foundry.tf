module "ai_foundry" {
  source = "azure/avm-ptn-aiml-ai-foundry/azurerm"
  version = "0.7.0"

  base_name = "sample"
  location = var.location
  resource_group_resource_id = azurerm_resource_group.main.id

  create_private_endpoints = true
  private_endpoint_subnet_resource_id = module.vnet_main.subnets["private_endpoints"].resource_id
  
  # don't share data with Microsoft
  enable_telemetry = false

  ai_foundry = {
    name = "aif-${var.workload}-${var.environment}"
    disable_local_auth = true
  }

  resource_names = {

  }

  ai_model_deployments = {
    "gpt-4o" = {
      name = "gpt-4o"
      model = {
        format = "OpenAI"
        name = "gpt-4o"
        version = "2024-11-20"
      }
      scale = {
        type = "Standard"
        capacity = 50
      }
    }
  }

  ai_projects = {
    "project1" = {
      name = "project1"
      display_name = "Project 1"
      description = "First AI Foundry Project"
    }
  }

  tags = var.tags
}