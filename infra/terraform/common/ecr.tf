resource "aws_ecr_repository" "api" {
  name                 = "${local.service_prefix}_app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
