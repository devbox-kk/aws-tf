variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
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
