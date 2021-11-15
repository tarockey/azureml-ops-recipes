variable "project_code" {
  type        = string
  description = "Project code such as mlops"
}

variable "env_code" {
  type        = string
  description = "Environment code such as dev or prod"
}

variable "location" {
  type        = string
  description = "Location where the resources should be created"
  default     = "West US 2"
}

variable "enable_private_endpoints" {
  type        = bool
  description = "Deploy AML with PrivateLink or not"
  default     = true
}

variable "enable_log_analytics" {
  type        = bool
  description = "Configure AML workspace and its Application Insights with sending Diagnistic events and metrics to a Log Analytics Workspace"
  default     = true
}

variable "log_analytics_workspace" {
  type        = string
  description = "Resource ID of an existing Log Analytics Workspace"
  default     = ""
}
