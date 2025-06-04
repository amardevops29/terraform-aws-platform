variable "environment" {
  description = "The environment name (e.g. dev, test, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "project" {
  description = "Name of the project"
  type = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)  
  default     = {}
}
