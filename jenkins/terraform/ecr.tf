resource "aws_ecr_repository" "bootifulmicropizza_build_tools" {
  name                 = "build-tools"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repo_url" {
  value = aws_ecr_repository.bootifulmicropizza_build_tools.repository_url
}

output "ecr_registry_id" {
  value = aws_ecr_repository.bootifulmicropizza_build_tools.registry_id
}
