resource "aws_ecs_task_definition" "api" {
  family                   = "${local.app_name}-api"
  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role_api.arn
  network_mode             = "awsvpc"
  container_definitions    = <<-EOS
  [
    {
        "name": "${local.app_name}-api",
        "image": "${aws_ecr_repository.api.repository_url}:${local.ecs_api_tag}",
        "cpu": 0,
        "portMappings": [
            {
                "name": "${local.app_name}-api",
                "containerPort": 80,
                "hostPort": 80,
                "protocol": "tcp",
                "appProtocol": "http"
            }
        ],
        "essential": true,
        "environment": [],
        "environmentFiles": [],
        "mountPoints": [],
        "volumesFrom": [],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-create-group": "true",
                "awslogs-group": "/ecs/${local.app_name}-api",
                "awslogs-region": "ap-northeast-1",
                "awslogs-stream-prefix": "ecs"
            }
        }
    }
  ]
  EOS
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

resource "aws_iam_role" "ecs_task_execution_role_api" {
  name = "${local.app_name}-api-task-execution-role"

  assume_role_policy = <<-EOS
  {
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  }
  EOS
}

resource "aws_iam_policy" "ecs_task_execution_role_policy_api" {
  name   = "${local.app_name}-api-ecs-task-execution-role-policy"
  policy = <<-EOS
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        }
    ]
  }
  EOS
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_api" {
  role       = aws_iam_role.ecs_task_execution_role_api.name
  policy_arn = aws_iam_policy.ecs_task_execution_role_policy_api.arn
}

resource "aws_security_group" "ecs_service_api" {
  name        = "${local.app_name}-api"
  description = "${local.app_name}-api"
  vpc_id      = aws_vpc.this.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.app_name}-api"
  }
}

resource "aws_ecs_service" "api" {
  name            = "${local.app_name}-api"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.api.arn
  launch_type     = "FARGATE"
  desired_count   = local.ecs_api_count
  network_configuration {
    subnets = [
      for k, v in local.public_subnets :
      aws_subnet.public[k].id
    ]
    security_groups = [
      aws_security_group.ecs_service_api.id
    ]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.api_http.arn
    container_name   = "${local.app_name}-api"
    container_port   = 80
  }
}
