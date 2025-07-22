output "task_role_arn" {
  description = "ARN of the task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "execution_role_arn" {
  description = "ARN of the execution role"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda@Edge role"
  value       = aws_iam_role.lambda_role.arn
}
