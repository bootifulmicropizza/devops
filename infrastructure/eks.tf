module "eks" {
  source  = "github.com/bootifulmicropizza/terraform-modules/eks"
  
  environment = var.environment
  aws_region = var.aws_region
}
