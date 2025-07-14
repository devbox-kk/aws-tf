variable "load_balancer_type" {
  description = "Type of load balancer (application or network)"
  type        = string
  default     = "application"
  validation {
    condition     = contains(["application", "network"], var.load_balancer_type)
    error_message = "Load balancer type must be either 'application' or 'network'."
  }
}

variable "load_balancer_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for ALB"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the target groups will be created"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the load balancer"
  type        = bool
  default     = false
}

variable "target_groups" {
  description = "List of target groups configuration"
  type = list(object({
    name     = string
    port     = number
    protocol = string
    health_check = object({
      enabled             = bool
      healthy_threshold   = number
      interval            = number
      matcher             = string
      path                = string
      port                = string
      protocol            = string
      timeout             = number
      unhealthy_threshold = number
    })
  }))
  default = []
}

variable "listeners" {
  description = "List of listeners configuration"
  type = list(object({
    port            = number
    protocol        = string
    ssl_policy      = string
    certificate_arn = string
    default_action = object({
      type               = string
      target_group_index = number
    })
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
