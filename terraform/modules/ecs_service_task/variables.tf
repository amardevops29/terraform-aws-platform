variable "cluster_name" {
  description = "ECS cluster ID or name"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
}


variable "container_port" {
  description = "Port the container exposes"
  type        = number
}

variable "host_port" {
  description = "Port the host exposes"
  type        = number
}

variable "image" {
  description = "Docker image to use"
  type        = string
  default     = "amazon/amazon-ecs-sample"
}

variable "cpu" {
  description = "Task CPU"
  type        = string
  default     = "512"
}

variable "memory" {
  description = "Task memory"
  type        = string
  default     = "1024"
}

variable "execution_role_arn" {
  description = "IAM role for task execution"
  type        = string  
}

variable "subnets" {
  description = "Subnets for ECS service"
  type        = list(string)  
}

variable "security_groups" {
  description = "Security groups"
  type        = list(string) 
}

variable "target_group_arn" {
  description = "Target group ARN for ALB"
  type        = string
}

variable "capacity_provider" {
  description = "ECS capacity provider name"
  type        = string
}

variable "aws_cloudwatch_log_group" {
  description = "The name of the CloudWatch Log Group to be used by ECS container logs"
  type        = string
}