
# Security Group for ECS
resource "aws_security_group" "HR_ec2_securitygroup" {
  name        = "${var.environment}-${var.project}-app-sg"
  description = "Security group for ECS container instances (EC2)"
  vpc_id      = aws_vpc.HR_VPC.id

  ingress {
    description = "Allow HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Allow ALB to forward to application port"
    from_port       = 5004
    to_port         = 5004
    protocol        = "tcp"
  }

  ingress {
    description     = "Allow ALB to forward to dynamic ports"
    from_port       = 51678
    to_port         = 51678
    protocol        = "tcp"
  }

  # Allow SSH (optional for management)
  ingress {
    description = "Allow SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-${var.project}-app-sg"
    Environment = var.environment
    Project     = var.project
  }
}

# Security Group for EC2 Instance
#resource "aws_security_group" "Ec2_securitygroup_DB" {
 # name        = "Mongod_postgres_SG"
  #description = "Security group for EC2 instance"
  #vpc_id      = aws_vpc.HR_VPC.id

  #ingress {
   # description = "SSH"
   # from_port = 22
   # to_port   = 22
   # protocol  = "tcp"
   # cidr_blocks = ["0.0.0.0/0"]
  #}
  #ingress {
   # description = "PostgreSQL"
   # from_port = 5432
   # to_port   = 5432
   # protocol  = "tcp"
   # cidr_blocks = ["0.0.0.0/0"]
  #}

   #ingress {
    #description = "MongoDB"
    #from_port   = 27017
    #to_port     = 27017
    #protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
  #}
  
  #egress {
   # from_port = 0
   # to_port = 0
   # protocol = "-1"
   # cidr_blocks = ["0.0.0.0/0"]
   #}

   #tags = {
    #Name = "Mongod_postgres_SG"
  #}
#}