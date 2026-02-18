terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
    bucket         = "devops-assignment-tf-state-prithvirajreddy" # You need to create this bucket manually or via script
    key            = "aws/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-assignment-tf-lock" # You need to create this table manually or via script
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
