output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "capacity_provider_name" {
  description = "The name of the ECS capacity provider"
  value       = aws_ecs_capacity_provider.this.name
}

output "autoscaling_group_arn" {
  description = "The ARN of the ECS Auto Scaling Group"
  value       = aws_autoscaling_group.hr_ecs_asg.arn
}