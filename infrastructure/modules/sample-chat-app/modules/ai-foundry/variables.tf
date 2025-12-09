variable "resource_name" {
  description = "Overrides the default name of the AI Foundry resource."
  type        = string
  default = null
}

variable "location" {
  description = "The Azure region to deploy resources into."
  type        = string
  default     = "East US"
}

variable "workload" {
  description = "The name of the application workload."
  type = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)."
  type = string
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy AI Foundry into."
  type        = string
}

variable "use_private_endpoints" {
  description = "Whether to enable private endpoints for the AI Foundry resource."
  type        = bool
  default     = true
}

variable "private_endpoint_subnet_id" {
  description = "The resource ID of the subnet to use for private endpoints."
  type        = string
  default     = null
  validation {
    condition     = var.use_private_endpoints == false || var.private_endpoint_subnet_id != null
    error_message = "private_endpoint_subnet_id must be provided when use_private_endpoints is true."
  }
}

variable "ai_foundry_sku" {
  description = "The SKU for the AI Foundry resource."
  type        = string
  default     = "S0"
}

variable "model_deployments" {
  description = <<-DESCRIPTION
    Map of AI model deployment configurations.
    The key is the deployment name, and the value is an object with the following properties:
      - name: The name of the model deployment (e.g. "gpt-4o").
      - version: The version of the model to deploy (e.g. "2024-08-06").
      - format: The format of the model (e.g., "OpenAI", "ONNX").
      - sku_name (optional): The SKU name for the deployment (default: "GlobalStandard").
      - sku_capacity (optional): The capacity for the deployment SKU (default: 1).
  DESCRIPTION
  type = map(object({
    name = string
    version = string
    format = string
    sku_name = optional(string, "GlobalStandard")
    sku_capacity = optional(number, 1)
  }))
  default = {}
}

variable "managed_identity_id" {
  description = "The resource ID of the managed identity to assign to AI Foundry."
  type        = string
  default = null
}