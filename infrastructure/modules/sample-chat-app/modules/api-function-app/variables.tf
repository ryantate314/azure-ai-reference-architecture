variable "workload" {
  description = "The name of the workload"
  type        = string
}

variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources in"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "private_endpoints_subnet_id" {
  description = "The ID of the private endpoints subnet"
  type        = string
}

variable "app_service_plan_subnet_id" {
  description = "The ID of the app service plan subnet"
  type        = string
}

variable "blob_private_dns_zone_id" {
  description = "The ID of the private DNS zone for blob storage (privatelink.blob.core.windows.net)"
  type        = string
}
