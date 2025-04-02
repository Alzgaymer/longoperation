resource "aws_ecs_cluster" "api-long-operation-cluster" {
  name = "LongOperationAPI"
}

resource "aws_ecs_service" "api-long-operation" {
  name                 = "LongOperationAPI"
  launch_type          = "FARGATE"
  desired_count        = 1
  force_new_deployment = true

  cluster         = aws_ecs_cluster.api-long-operation-cluster.id
  task_definition = aws_ecs_task_definition.api-long-operation.arn

  network_configuration {
    subnets         = aws_subnet.private[*].id
    security_groups = [aws_security_group.long-operation-sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.fargate.arn
    container_name   = "api-long-operation"
    container_port   = 80
  }
}

resource "aws_ecs_task_definition" "api-long-operation" {
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  family                   = "api-long-operation"
  requires_compatibilities = ["FARGATE"]

  network_mode       = "awsvpc"
  cpu                = 256
  memory             = 512
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  //task_role_arn = ""
  container_definitions = jsonencode([
    {
      name   = "api-long-operation"
      image  = "${aws_ecr_repository.api-long_operation_registry.repository_url}/api-long-operation:latest"
      cpu    = 256
      memory = 512
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      user = "server"
    }
  ])
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}