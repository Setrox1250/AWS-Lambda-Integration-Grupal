provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "image-processor"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}