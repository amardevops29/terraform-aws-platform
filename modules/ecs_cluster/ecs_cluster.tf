# Create ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "${var.environment}-${var.cluster_name_suffix}-ecs-cluster"
}

# EC2 Launch Template
resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.environment}-${var.cluster_name_suffix}-ecs-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    cluster_name = aws_ecs_cluster.this.name
  }))

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

# Auto Scaling Group for ECS EC2 Instances
resource "aws_autoscaling_group" "hr_ecs_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-${var.cluster_name_suffix}-ecs-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Define ECS Capacity Provider linked to ASG
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

# Attach Capacity Provider to ECS Cluster
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [aws_ecs_capacity_provider.this.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
    base              = 1
  }
}
