terraform {
  # backend "s3" {}
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.name_prefix}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb"
  })
}

# Target Group
resource "aws_lb_target_group" "main" {

  name        = "${var.name_prefix}-tg"
  port        = var.target_groups.port
  protocol    = var.target_groups.protocol
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = var.target_groups.health_check.enabled
    healthy_threshold   = var.target_groups.health_check.healthy_threshold
    interval            = var.target_groups.health_check.interval
    matcher             = var.target_groups.health_check.matcher
    path                = var.target_groups.health_check.path
    port                = var.target_groups.health_check.port
    protocol            = var.target_groups.health_check.protocol
    timeout             = var.target_groups.health_check.timeout
    unhealthy_threshold = var.target_groups.health_check.unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-tg"
  })
}

# Listener
resource "aws_lb_listener" "main" {

  load_balancer_arn = aws_lb.main.arn
  port              = var.listeners.port
  protocol          = var.listeners.protocol
  ssl_policy        = var.listeners.ssl_policy
  certificate_arn   = var.listeners.certificate_arn

  default_action {
    type             = var.listeners.default_action.type
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-listener-${var.listeners.port}"
  })
}
