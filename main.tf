terraform {
  # cloud {
  #   organization = "adam-inc"
  #   workspaces {
  #     name = "web-app-prod"
  #   }
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_instance" "bastion" {
  ami           = "ami-0b28dfc7adc325ef4"
  instance_type = "t2.micro"
  tags = {
    Name = "bastion"
  }
}

resource "random_pet" "app" {
  length    = 2
  separator = "-"
}