terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "daengglejeju-tfstate"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-2"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws_region
}

# CloudFront ACM 인증서는 반드시 us-east-1이어야 함
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
