terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_ecr_repository" "showingflow_api" {
  name                 = "showingflow-api"
  image_tag_mutability = "MUTABLE"
}
