resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.HR_VPC.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-${var.project}-public-subnet"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  count                    = 2
  vpc_id                   = aws_vpc.HR_VPC.id
  cidr_block               = var.private_subnet_cidrs[count.index]
  availability_zone        = var.azs[count.index]

  tags = {
    Name        = "${var.environment}-${var.project}-private-subnet-${count.index}"
    Environment = var.environment
    Project     = var.project
  }
}
