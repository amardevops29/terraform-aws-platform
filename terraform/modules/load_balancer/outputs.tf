output "alb_arn" {
  description = "The ARN of the Application Load Balancer."
  value = aws_lb.app_alb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer used to route traffic."
  value = aws_lb.app_alb.dns_name
}

output "app_tg_arn" {
  description = "The ARN of the target group associated with the ECS service."
  value = aws_lb_target_group.app_tg.arn
}
