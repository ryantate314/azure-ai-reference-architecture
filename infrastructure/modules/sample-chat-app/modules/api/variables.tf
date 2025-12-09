variable "type" {
  description = "The type of backend, e.g. functionapp, appservice, containerservice"
  type        = string
  default     = "appservice"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "workload" {
  description = "The name of the workload"
  type        = string
  default     = "samplechatapp"
}

variable "environment" {
  description = "The deployment environment"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The Azure region to deploy resources in"
  type        = string
  default     = "East US"
}

variable "llm_endpoint" {
  description = "The endpoint URL for the LLM service"
  type        = string
}

variable "app_service_plan_subnet_id" {
  description = "The ID of the app service plan subnet"
  type        = string
}

variable "image_name" {
  type = string
}

variable "docker_registry_url" {
  type = string
}

variable "user_assigned_identity_id" {
  description = "The ID of the user assigned identity for the app service"
  type        = string
}

variable "user_assigned_acr_identity_client_id" {
  description = "The client ID of the user assigned identity for ACR access"
  type        = string
}