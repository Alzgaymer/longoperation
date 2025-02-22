resource "aws_ecs_task_definition" "api-long-operation" {
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  family                   = "api-long-operation"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1
  memory                   = 16
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "api-long-operation",
    "hostname": "api-long-operation",
    "image": "${aws_ecr_repository.oci_registry.repository_url}/api-long-operation:latest",
    "cpu": 1,
    "memory": 16,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "user": "server"
  }
]
TASK_DEFINITION
}