variable "cluster_name_suffix" {
  type        = string
  description = "Suffix for the ECS cluster name (e.g. hr, finance, attendance)"
}

variable "environment" {
  description = "The environment name (e.g. dev, test, prod)"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "ID of the public subnet"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
