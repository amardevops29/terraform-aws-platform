output "execution_role_arn" {
  description = "The ARN of the ECS task execution IAM role"
  value = (
    var.role_name == "ecs-task-execution-role" ? aws_iam_role.ecs_task_execution_role[0].arn :
    var.role_name == "ecs-instance-role" ? aws_iam_role.ecs_instance_role[0].arn : 
    null
  )
}

output "instance_profile_name" {
  description = "The ARN of the ECS instance IAM role"
  value = var.role_name == "ecs-instance-role" ? aws_iam_instance_profile.ecs_instance_profile[0].name : null
}
