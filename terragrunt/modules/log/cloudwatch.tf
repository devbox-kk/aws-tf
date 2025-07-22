terraform {
  # backend "s3" {}
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  name              = "${var.name_prefix}-log-group"
  retention_in_days = var.log_retention_days

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-log-group"
  })
}
