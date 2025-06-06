variable "project" {
  type = string
}

variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g. dev, test, prod)"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to associate with the security group"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    description = optional(string)
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    description = optional(string)
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}
}
