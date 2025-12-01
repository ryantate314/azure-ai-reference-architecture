variable location {
  description = "The Azure region to deploy resources into."
  type        = string
  default     = "East US"
}

variable resource_group_name {
  description = "The name of the resource group to deploy resources into."
  type        = string
  default     = "ai-foundry-reference-architecture"
}

variable resource_group_id {
  description = "The resource group ID to deploy resources into."
  type        = string
}

variable ip_ranges {
  type = object({
    virtual_network = string
    bastion = string
    jump_box = string
  })
}

variable subscription_id {
  description = "The Azure Subscription ID where resources will be deployed."
  type        = string
}

variable bastion_password {
  description = "The password for the Bastion host VM."
  type        = string
}

variable "deploy_bastion" {
  description = "Whether to deploy the Bastion host and jump box VM."
  type        = bool
  default     = true
}