output "role_arn" {
  description = "ARN of the IAM role"
  value       = var.create_role ? aws_iam_role.main[0].arn : null
}

output "role_name" {
  description = "Name of the IAM role"
  value       = var.create_role ? aws_iam_role.main[0].name : null
}

output "policy_arn" {
  description = "ARN of the IAM policy"
  value       = var.create_policy ? aws_iam_policy.main[0].arn : null
}

output "user_arn" {
  description = "ARN of the IAM user"
  value       = var.create_user ? aws_iam_user.main[0].arn : null
}

output "user_name" {
  description = "Name of the IAM user"
  value       = var.create_user ? aws_iam_user.main[0].name : null
}

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = var.create_instance_profile ? aws_iam_instance_profile.main[0].arn : null
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = var.create_instance_profile ? aws_iam_instance_profile.main[0].name : null
}
