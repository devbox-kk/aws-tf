variable "create_log_group" {
  description = "Whether to create CloudWatch log group"
  type        = bool
  default     = false
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 14
}

variable "metric_alarms" {
  description = "List of CloudWatch metric alarms"
  type = list(object({
    alarm_name          = string
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = string
    namespace           = string
    period              = number
    statistic           = string
    threshold           = number
    alarm_description   = string
    alarm_actions       = list(string)
    dimensions          = map(string)
  }))
  default = []
}

variable "create_dashboard" {
  description = "Whether to create CloudWatch dashboard"
  type        = bool
  default     = false
}

variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  type        = string
  default     = ""
}

variable "dashboard_body" {
  description = "JSON body of the CloudWatch dashboard"
  type        = string
  default     = ""
}

variable "event_rules" {
  description = "List of CloudWatch event rules"
  type = list(object({
    name                = string
    description         = string
    event_pattern       = string
    schedule_expression = string
  }))
  default = []
}

variable "event_targets" {
  description = "List of CloudWatch event targets"
  type = list(object({
    rule_index = number
    target_id  = string
    arn        = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
