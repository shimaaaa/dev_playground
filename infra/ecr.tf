resource "aws_ecr_repository" "default" {
  name                 = "playground_app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
