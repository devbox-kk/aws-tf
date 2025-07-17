terraform {
  # backend "s3" {}
}

# IAM Role
resource "aws_iam_role" "main" {
  count = var.create_role ? 1 : 0

  name               = var.role_name
  assume_role_policy = var.assume_role_policy

  tags = merge(var.tags, {
    Name = var.role_name
  })
}

# IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "main" {
  count = var.create_role && length(var.policy_arns) > 0 ? length(var.policy_arns) : 0

  role       = aws_iam_role.main[0].name
  policy_arn = var.policy_arns[count.index]
}

# IAM Policy
resource "aws_iam_policy" "main" {
  count = var.create_policy ? 1 : 0

  name        = var.policy_name
  description = var.policy_description
  policy      = var.policy_document

  tags = merge(var.tags, {
    Name = var.policy_name
  })
}

# IAM User
resource "aws_iam_user" "main" {
  count = var.create_user ? 1 : 0

  name = var.user_name

  tags = merge(var.tags, {
    Name = var.user_name
  })
}

# IAM User Policy Attachment
resource "aws_iam_user_policy_attachment" "main" {
  count = var.create_user && length(var.user_policy_arns) > 0 ? length(var.user_policy_arns) : 0

  user       = aws_iam_user.main[0].name
  policy_arn = var.user_policy_arns[count.index]
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "main" {
  count = var.create_instance_profile ? 1 : 0

  name = var.instance_profile_name
  role = var.create_role ? aws_iam_role.main[0].name : var.existing_role_name

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = var.instance_profile_name
  })
}
