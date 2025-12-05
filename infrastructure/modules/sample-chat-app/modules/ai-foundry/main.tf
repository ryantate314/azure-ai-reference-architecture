locals {
  ai_model = {
    name    = "gpt-4o"
    version = "2024-11-20"
    format  = "OpenAI"
  }
}

resource "random_string" "ai_foundry" {
  length = 6
  special = false
  upper = false
}

module "ai_foundry" {
  source = "azure/avm-ptn-aiml-ai-foundry/azurerm"
  version = "0.7.0"

  base_name = "sample"
  location = var.location
  resource_group_resource_id = var.resource_group_id

  create_private_endpoints = true
  private_endpoint_subnet_resource_id = var.private_endpoint_subnet_id
  
  # don't share data with Microsoft
  enable_telemetry = false

  ai_foundry = {
    name = "aif-${var.workload}-${var.environment}-${random_string.ai_foundry.result}"
    disable_local_auth = true
  }

  resource_names = {

  }

  ai_model_deployments = {
    "gpt-4o" = {
      name = local.ai_model.name
      model = {
        format = local.ai_model.format
        name = local.ai_model.name
        version = local.ai_model.version
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