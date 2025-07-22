variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
