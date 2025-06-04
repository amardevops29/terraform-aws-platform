# ----------------------------------------------------------------------------------------
# VPC Module: Creates a Virtual Private Cloud (VPC) along with public and private subnets.
# It uses environment-specific CIDRs and Availability Zones.
# ----------------------------------------------------------------------------------------
module "vpc" {
  source               = "./modules/network"
  project              = var.project       # e.g., "hr"
  environment          = var.environment   # e.g., "dev","test","prod"  
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  tags = {
    Environment = var.environment    
  } 
}

module "ecs_instance_sg" {
  source      = "./modules/security_group"
  environment = var.environment
  project     = var.project
  name        = "ecs-instance-sg"
  description = "SG for ECS EC2 instances"
  vpc_id      = module.vpc.vpc_id
  ingress_rules = [
    {
      description = "Allow all traffic from VPC"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr]
    }
  ]
  egress_rules = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  tags = {
    Name        = "ecs-instance-sg"
    Environment = var.environment
  }
}


# -----------------------------------------------------------------------------
# Load Balancer Security Group
# -----------------------------------------------------------------------------
module "lb_sg" {
  source      = "./modules/security_group"
  project     = var.project       # e.g., "hr"
  name        = "lb-sg"
  environment = var.environment   # e.g., "dev","test","prod"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      description = "Allow all egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# Application Security Group (ECS/Fargate Backend)
# -----------------------------------------------------------------------------
module "app_sg" {
  source      = "./modules/security_group"
  project     = var.project       # e.g., "hr"
  name        = "app-sg"
  environment = var.environment   # e.g., "dev","test","prod"
  description = "Security group for app containers"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "Allow traffic from ALB"
      from_port   = 80             # Later change to 5004 
      to_port     = 80             # Later change to 5004 
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  # Replace with [module.lb_sg.id] if using SG referencing
    }
  ]

  egress_rules = [
    {
      description = "Allow all egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Environment = var.environment
  }
}

# --------------------------------------------------------------------------------------
# ECR Module: Creates an Amazon Elastic Container Registry (ECR) repository for storing 
# Docker container images related to the HR application.
# --------------------------------------------------------------------------------------
module "ecr" {
  source    = "./modules/ecr"
  app_name  = "hr-app"
}

# --------------------------------------------------------------------------------------------
# ECS Cluster Module: Provisions an ECS cluster with EC2 instances using the specified AMI ID 
# and instance type. Subnets and VPC are pulled from the VPC module.
# --------------------------------------------------------------------------------------------
module "hr_cluster" {
  source                = "./modules/ecs_cluster"
  environment           = var.environment
  cluster_name_suffix   = "hr"
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  private_subnet_ids    = module.vpc.private_subnet_ids
  public_subnet_ids     = module.vpc.public_subnet_ids
  vpc_id                = module.vpc.vpc_id  
  ecs_instance_sg_id    = module.ecs_instance_sg.security_group_id
  execution_role_arn    = module.ecs_task_iam_role.execution_role_arn
  instance_profile_name = module.ecs_instance_role.instance_profile_name

}

# ----------------------------------------------------------------------------------------------
# Load Balancer Module: This module creates an Application Load Balancer (ALB), a target group,
# and an HTTP listener for forwarding traffic to ECS or other services.
# ----------------------------------------------------------------------------------------------
module "load_balancer" {
  source               = "./modules/load_balancer"       # Path to the reusable module
  # ---------------- ALB Configuration ----------------
  alb_name             = "hr-app-alb"  
  # VPC and Subnet Setup
  vpc_id               = module.vpc.vpc_id              # VPC where ALB and TG will be created
  public_subnet_ids    = module.vpc.public_subnet_ids   # Subnets to associate with ALB (typically public subnets)
  # Security Group(s) for ALB
  security_group_ids = [module.lb_sg.id]             # Security group allowing inbound HTTP/HTTPS traffic
  # Tagging and Environment Context
  environment = var.environment                      # Used for tagging and logical separation (e.g., dev/test/prod)
  # ---------------- Target Group Configuration ----------------
  target_group_name    = "hr-app-tg"                    # Name for the target group
  target_group_port    = 80                             # Port on which targets receive traffic
  protocol             = "HTTP"                         # Protocol for the target group (HTTP or HTTPS)
  target_type          = "ip"                           # Target type: 'ip' for ECS/Fargate, 'instance' for EC2
  # ---------------- Health Check Settings ----------------
  health_check_path    = "/"                         # URL path to perform health checks
  health_check_matcher = "200"                       # Expected HTTP code for healthy targets
}

# --------------------------------------------------------------------------------------------------------
# ECS Task Execution Role Module: This module creates an IAM role for ECS tasks with policies required to
# pull images from ECR and write logs to CloudWatch.
# --------------------------------------------------------------------------------------------------------
module "ecs_task_iam_role" {
  source = "./modules/iam"
  role_name = "ecs-task-execution-role"
  project     = var.project       # e.g., "hr"
  environment = var.environment      
}

# -----------------------------------------------------------------------------
# ECS Instance Role Module
# This module creates an IAM role for ECS Instance with policies required to
# -----------------------------------------------------------------------------
module "ecs_instance_role" {
  source      = "./modules/iam"
  role_name   = "ecs-instance-role"
  project     = var.project
  environment = var.environment
}

# -----------------------------------------------------------------------------
# AWS Cloudwatch log group: This module creates an cloudwatch logs for services
# -----------------------------------------------------------------------------
module "aws_cloudwatch_log_group" {
  source        = "./modules/cloudwatch_logs"
  service_name  = "hr-app" # or var.service_name if declared in root
}

# ---------------------------------------------------------------------------------------------
# ECS Service Task Module: Defines an ECS service and task definition for the HR application.
# This module creates a service with autoscaling capabilities and attaches it to the specified
# target group for load balancing. From this point forward, define as many ECS service task 
# modules as needed for your application stack by duplicating and customizing this block.
# ---------------------------------------------------------------------------------------------
module "ecs_service_task" {
  source                      = "./modules/ecs_service_task"
  aws_region                  = var.AWS_REGION
  cluster_name                = module.hr_cluster.ecs_cluster_name
  service_name                = "hr-app"
  container_name              = "sample-ecs"
  container_port              = 80      # Later change to 5004 or whichever port your container listens.
  host_port                   = 80      # Later change to host port
  execution_role_arn          = module.ecs_task_iam_role.execution_role_arn
  subnets                     = module.vpc.private_subnet_ids
  security_groups             = [module.app_sg.id]
  target_group_arn            = module.load_balancer.app_tg_arn
  capacity_provider           = module.hr_cluster.capacity_provider_name
  aws_cloudwatch_log_group    = module.aws_cloudwatch_log_group.log_group_name
  cpu                         = "512"
  memory                      = "1024"
}