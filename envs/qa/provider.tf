provider "aws" {
  region = "us-east-1"

  shared_config_files = [
    "/Users/tf_user/.aws/conf"
  ]

  shared_credentials_files = [
    "/Users/tf_user/.aws/creds"
  ]

  profile = "customprofile"

  default_tags {
    tags = {
      Project     = "image-processor"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}