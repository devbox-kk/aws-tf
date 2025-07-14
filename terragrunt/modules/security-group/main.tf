terraform {
  # backend "s3" {}
}

# Security Group
resource "aws_security_group" "main" {
  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = var.security_group_name
  })
}

# Security Group Rules - Ingress
resource "aws_security_group_rule" "ingress" {
  count = length(var.ingress_rules)

  type        = "ingress"
  from_port   = var.ingress_rules[count.index].from_port
  to_port     = var.ingress_rules[count.index].to_port
  protocol    = var.ingress_rules[count.index].protocol
  cidr_blocks = var.ingress_rules[count.index].cidr_blocks

  security_group_id = aws_security_group.main.id
}

# Security Group Rules - Egress
resource "aws_security_group_rule" "egress" {
  count = length(var.egress_rules)

  type        = "egress"
  from_port   = var.egress_rules[count.index].from_port
  to_port     = var.egress_rules[count.index].to_port
  protocol    = var.egress_rules[count.index].protocol
  cidr_blocks = var.egress_rules[count.index].cidr_blocks

  security_group_id = aws_security_group.main.id
}
