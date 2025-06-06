variable "AWS_REGION" {
  type        = string
  description = "The AWS region to be used"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR block for the public subnet"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Availability zones for subnets"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, test, prod)"
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "hr_ecs_cluster"
}

variable "project" {
  type        = string
  description = "Project or app name (e.g. hr, finance, api)"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for ECS instances"
  default = "ami-0fc5d935ebf8bc3bc"
}

variable "instance_type" {  
  type    = string  
  description = "EC2 instance type for ECS"
  default = "t3.medium"
}

variable "ECS_AMIS" {
  description = "Map of region to ECS Optimized AMI IDs"
  default = {
    us-east-1 = "ami-0fc5d935ebf8bc3bc"
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS service"
  type        = list(string)
  default     = []  # will be overridden with data source if needed
}
