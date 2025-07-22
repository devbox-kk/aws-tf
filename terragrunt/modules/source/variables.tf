variable "name_prefix" {
  description = "Prefix for the resource names"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "lifecycle_policy" {
  description = "The lifecycle policy document for the repository"
  type        = string
  default     = null
}

variable "repository_policy" {
  description = "The repository policy document for the repository"
  type        = string
  default     = null
}

variable "force_delete" {
  description = "If true, will delete the repository even if it contains images"
  type        = bool
  default     = false
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "block_public_access" {
  description = "Whether to block public access to the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_website_hosting" {
  description = "Whether to enable static website hosting"
  type        = bool
  default     = false
}
