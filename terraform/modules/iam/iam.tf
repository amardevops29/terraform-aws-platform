#--------IAM ROLE: ecs_task_execution_role ------------------------------------------------|
resource "aws_iam_role" "ecs_task_execution_role" {

  count = var.role_name == "ecs-task-execution-role" ? 1 : 0

  name               = "${var.environment}-${var.project}-${var.role_name}"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role[0].json

  tags = {
    Name = var.role_name
  }
}

data "aws_iam_policy_document" "ecs_assume_role" {

  count = var.role_name == "ecs-task-execution-role" ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  count = var.role_name == "ecs-task-execution-role" ? 1 : 0

  role       = aws_iam_role.ecs_task_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#--------IAM ROLE: ecs_instance_role ------------------------------------------------|
resource "aws_iam_role" "ecs_instance_role" {
  count = var.role_name == "ecs-instance-role" ? 1 : 0

  name = "${var.environment}-${var.project}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = var.role_name
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  count = var.role_name == "ecs-instance-role" ? 1 : 0

  role       = aws_iam_role.ecs_instance_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  count = var.role_name == "ecs-instance-role" ? 1 : 0

  name = "${var.environment}-${var.project}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role[0].name
}
