variable "name" {
  description = "The name of the Azure Machine Learning Workspace"
  type        = string
}

variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "log_analytics_workspace_name" {
  type = string
}

variable "application_insights_name" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "container_registry_name" {
  type = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "The tags to apply to the resources"
}

variable "enable_private_endpoint" {
  type    = bool
  default = false
}

variable "vnet_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "resource_prefix" {
  type    = string
  default = ""
}
