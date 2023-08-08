resource "aws_ecr_repository" "api" {
  name                 = "${local.prefix}_app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
