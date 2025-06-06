#-----------------------------------------------------------------------------------------------------
# Create ECS Cluster: This resource creates an ECS cluster to run ECS- elastic containerized services.
#-----------------------------------------------------------------------------------------------------
resource "aws_ecs_cluster" "this" {
  name = "${var.environment}-${var.cluster_name_suffix}-ecs-cluster"
}

#--------------------------------------------------------------------------------------------------------------------
# Get ECS Optimized AMI from SSM: This data source fetches the latest Amazon ECS-optimized AMI ID for Amazon Linux 2.
# -------------------------------------------------------------------------------------------------------------------
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# ------------------------------------------------------------------------------------------------------
# EC2 Launch Template: This template defines EC2 instance configuration for the ECS cluster, including:
# - AMI
# - Instance type
# - IAM instance profile for ECS
# - Security groups
# - User data for ECS agent configuration
# - Tagging and lifecycle policy
# ------------------------------------------------------------------------------------------------------
resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.environment}-${var.cluster_name_suffix}-ecs-lt"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    cluster_name = aws_ecs_cluster.this.name
  }))

  # This ensures the EC2 instance gets a public IP
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.ecs_instance_sg_id]  # pass this from VPC module or variable
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-${var.cluster_name_suffix}-ecs-instance"
    }
  }
}

# ----------------------------------------------------------------------------------------------------------
# Auto Scaling Group for ECS EC2 Instances: This ASG launches ECS instances using the above launch template.
# It defines min/max/desired capacity and subnet placement.
# It also applies tags required for ECS to register EC2 instances with the cluster.
# ----------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "hr_ecs_asg" {
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-${var.cluster_name_suffix}-ecs-instance"
    propagate_at_launch = true
  }

   tag {
    key                 = "AmazonECSCluster"
    value               = aws_ecs_cluster.this.name
    propagate_at_launch = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------------------
# Define ECS Capacity Provider linked to ASG: This links the above Auto Scaling Group with the ECS cluster via a capacity provider.
# ECS can now scale EC2 instances using this capacity provider.
# ---------------------------------------------------------------------------------------------------------------------------------
resource "aws_ecs_capacity_provider" "this" {
  name = "${var.environment}-${var.cluster_name_suffix}-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.hr_ecs_asg.arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 80
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1000
    }

    managed_termination_protection = "DISABLED"
  }
}

# ----------------------------------------------------------------------------------------------------------------------------
# Attach Capacity Provider to ECS Cluster : # This ties the created capacity provider to the ECS cluster so that ECS services
# can use it as the default capacity provider.
# ----------------------------------------------------------------------------------------------------------------------------
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [aws_ecs_capacity_provider.this.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
    base              = 1
  }
}