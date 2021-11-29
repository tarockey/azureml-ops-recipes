variable "azureml_workspace" {
  type        = string
  description = "Resource ID of an existing Azure Machine Learning Workspace"
}

variable "existing_log_analytics_workspace" {
  type        = string
  description = "Resource ID of an existing Log Analytics Workspace"
  default     = ""
}

variable "log_analytics_sku" {
  type    = string
  default = "PerGB2018"
}

variable "log_analytics_retention_in_days" {
  type    = number
  default = 90
}

variable "log_analytics_tags" {
  type        = map(string)
  default     = {}
  description = "The tags to associate to resources"
}

