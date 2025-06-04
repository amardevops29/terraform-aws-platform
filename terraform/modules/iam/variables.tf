variable "role_name" {
  description = "Name of the IAM role for ECS task execution"
  type        = string
}

variable "project" {
  description = "Name of the project"
  type = string
}

variable "environment" {
  description = "Deployment environment (dev/test/prod)"
  type        = string
}