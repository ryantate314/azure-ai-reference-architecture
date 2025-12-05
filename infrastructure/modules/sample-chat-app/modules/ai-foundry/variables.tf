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

variable "resource_group_id" {
  description = "The ID of the resource group to deploy AI Foundry into."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "The resource ID of the subnet to use for private endpoints."
  type        = string
}