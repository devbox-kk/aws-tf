variable "create_role" {
  description = "Whether to create IAM role"
  type        = bool
  default     = false
}

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = ""
}

variable "assume_role_policy" {
  description = "Assume role policy document"
  type        = string
  default     = ""
}

variable "policy_arns" {
  description = "List of policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "create_policy" {
  description = "Whether to create IAM policy"
  type        = bool
  default     = false
}

variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = ""
}

variable "policy_description" {
  description = "Description of the IAM policy"
  type        = string
  default     = ""
}

variable "policy_document" {
  description = "IAM policy document"
  type        = string
  default     = ""
}

variable "create_user" {
  description = "Whether to create IAM user"
  type        = bool
  default     = false
}

variable "user_name" {
  description = "Name of the IAM user"
  type        = string
  default     = ""
}

variable "user_policy_arns" {
  description = "List of policy ARNs to attach to the user"
  type        = list(string)
  default     = []
}

variable "create_instance_profile" {
  description = "Whether to create instance profile"
  type        = bool
  default     = false
}

variable "instance_profile_name" {
  description = "Name of the instance profile"
  type        = string
  default     = ""
}

variable "existing_role_name" {
  description = "Name of existing role to use for instance profile"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
