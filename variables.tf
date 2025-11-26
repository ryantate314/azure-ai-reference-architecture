variable "location" {
  description = "The Azure region to deploy resources into."
  type        = string
  default     = "East US"
}

variable "subscription_id" {
  description = "The Azure Subscription ID to deploy resources into."
  type        = string
}