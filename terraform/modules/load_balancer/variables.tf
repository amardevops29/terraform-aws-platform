variable "alb_name" {
  description = "Name of the ALB"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with ALB"
  type        = list(string)
}

variable "environment" {
  description = "Deployment environment (dev/test/prod)"
  type        = string
}

# Target Group variables
variable "target_group_name" {
  description = "The name of the target group used by the Application Load Balancer to route traffic."
  type = string
}

variable "target_group_port" {
  description = "The port on which targets receive traffic. Common default is port 80 for HTTP."
  type    = number
  default = 80
}

variable "protocol" {
  description = "The protocol used for routing traffic to targets. Typically 'HTTP' or 'HTTPS'."
  type    = string
  default = "HTTP"
}

variable "target_type" {
  description = "The type of target to register with the target group. Valid values: 'instance', 'ip', or 'lambda'."
  type    = string
  default = "ip"
}

# Health check parameters
variable "health_check_path" {
  description = "The destination path the load balancer uses to perform health checks on targets."
  type    = string
  default = "/"
}

variable "health_check_interval" {
  description = "The approximate amount of time, in seconds, between health checks of an individual target."
  type    = number
  default = 30
}

variable "health_check_timeout" {
  description = "The amount of time, in seconds, during which no response means a failed health check."
  type    = number
  default = 5
}

variable "health_check_healthy_threshold" {
  description = "The number of consecutive successful health checks required for a target to be considered healthy."
  type    = number
  default = 2
}

variable "health_check_unhealthy_threshold" {
  description = "The number of consecutive failed health checks required for a target to be considered unhealthy."
  type    = number
  default = 2
}

variable "health_check_matcher" {
  description = "The HTTP status code(s) to match when checking for a healthy target. For example, '200' means OK."
  type    = string
  default = "200"
}
