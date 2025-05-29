output "vpc_id" {
  value = aws_vpc.HR_VPC.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
