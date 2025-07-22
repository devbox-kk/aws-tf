variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "create_role" {
  description = "Whether to create IAM role"
  type        = bool
  default     = false
}

variable "assume_role_policy" {
  description = "Assume role policy document"
  type        = string
  default     = ""
}

variable "policy_arn" {
  description = "Policy ARN to attach to the role"
  type        = string
  default     = ""
}
