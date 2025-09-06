terraform {
  required_version = ">=1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
  }

  backend "s3" {
    bucket = "defmania-tf-state-bucket-prod"
    key    = "project-vs-webapp/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      "created-by"       = "terraform"
      "environment"      = "prod"
      "application-name" = "Vegan-Studio-Project"
    }
  }
}
