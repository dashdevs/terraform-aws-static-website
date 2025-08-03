terraform {
  required_version = ">= 1.5.2"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.34"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
  }
}

provider "aws" {
  region = "us-east-1"
} 