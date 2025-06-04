output "vpc_id" {
  description = "The ID of the created VPC."
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "The CIDR block associated with the VPC."
  value = var.vpc_cidr
}

output "public_subnet_ids" {
  description = "A list of IDs for the public subnets in the VPC."
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "A list of IDs for the private subnets in the VPC."
  value = aws_subnet.private[*].id
}

output "public_route_table_id" {
  description = "The ID of the route table associated with public subnets."
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "The ID of the route table associated with private subnets."
  value = aws_route_table.private.id
}