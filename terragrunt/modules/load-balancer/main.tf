terraform {
  # backend "s3" {}
}

# Application Load Balancer
resource "aws_lb" "main" {
  count = var.load_balancer_type == "application" ? 1 : 0

  name               = var.load_balancer_name
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, {
    Name = var.load_balancer_name
  })
}

# Network Load Balancer
resource "aws_lb" "network" {
  count = var.load_balancer_type == "network" ? 1 : 0

  name               = var.load_balancer_name
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, {
    Name = var.load_balancer_name
  })
}

# Target Group
resource "aws_lb_target_group" "main" {
  count = length(var.target_groups)

  name     = var.target_groups[count.index].name
  port     = var.target_groups[count.index].port
  protocol = var.target_groups[count.index].protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = var.target_groups[count.index].health_check.enabled
    healthy_threshold   = var.target_groups[count.index].health_check.healthy_threshold
    interval            = var.target_groups[count.index].health_check.interval
    matcher             = var.target_groups[count.index].health_check.matcher
    path                = var.target_groups[count.index].health_check.path
    port                = var.target_groups[count.index].health_check.port
    protocol            = var.target_groups[count.index].health_check.protocol
    timeout             = var.target_groups[count.index].health_check.timeout
    unhealthy_threshold = var.target_groups[count.index].health_check.unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = var.target_groups[count.index].name
  })
}

# Listener
resource "aws_lb_listener" "main" {
  count = length(var.listeners)

  load_balancer_arn = var.load_balancer_type == "application" ? aws_lb.main[0].arn : aws_lb.network[0].arn
  port              = var.listeners[count.index].port
  protocol          = var.listeners[count.index].protocol
  ssl_policy        = var.listeners[count.index].ssl_policy
  certificate_arn   = var.listeners[count.index].certificate_arn

  default_action {
    type             = var.listeners[count.index].default_action.type
    target_group_arn = aws_lb_target_group.main[var.listeners[count.index].default_action.target_group_index].arn
  }

  tags = merge(var.tags, {
    Name = "${var.load_balancer_name}-listener-${var.listeners[count.index].port}"
  })
}
