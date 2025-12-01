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
  description = "The environment abbreviation, e.g. dev, test, prod."
  type = string
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

variable "ip_ranges" {
  type = object({
    virtual_network = string
    private_endpoints = string
    app_service_plan = string
  })
}

variable "hub_vnet_id" {
  description = "The resource ID of the hub virtual network to peer with."
  type        = string
}