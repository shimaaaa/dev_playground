locals {
  app_name = "${var.service_prefix}-${var.env}"
}



data "aws_ecr_repository" "api" {
  name = "${var.service_prefix}_app"

}


data "aws_ecr_repository" "otel_collector" {
  name = "aws-otel-collector"
}
