# main.tf

provider "aws" {
  region = "us-east-1" # La región puede ser modificada según la preferencia
}

resource "aws_ecr_repository" "flask_api_repo" {
  name = "flask-api-repo"
}

resource "aws_ecs_cluster" "flask_api_cluster" {
  name = "flask-api-cluster"
}

resource "aws_ecs_task_definition" "flask_api_task" {
  family                   = "flask-api-task"
  container_definitions    = file("${path.module}/task-definition.json")
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"
}

resource "aws_ecs_service" "flask_api_service" {
  name            = "flask-api-service"
  cluster         = aws_ecs_cluster.flask_api_cluster.id
  task_definition = aws_ecs_task_definition.flask_api_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-12345678"] # Sustituir con subnets válidas
    security_groups = ["sg-12345678"]     # Sustituir con security groups válidos
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.flask_api_task]
}

resource "aws_api_gateway_rest_api" "flask_api_gateway" {
  name = "flask-api-gateway"
}

resource "aws_api_gateway_resource" "flask_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.flask_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.flask_api_gateway.root_resource_id
  path_part   = "flask"
}

resource "aws_api_gateway_method" "flask_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.flask_api_gateway.id
  resource_id   = aws_api_gateway_resource.flask_api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "flask_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.flask_api_gateway.id
  resource_id             = aws_api_gateway_resource.flask_api_resource.id
  http_method             = aws_api_gateway_method.flask_api_method.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = aws_ecs_service.flask_api_service.load_balancer_dns_name # La URL del servicio Fargate
}

resource "aws_api_gateway_deployment" "flask_api_deployment" {
  depends_on = [aws_api_gateway_integration.flask_api_integration]
  rest_api_id = aws_api_gateway_rest_api.flask_api_gateway.id
  stage_name = "prod"
}
