terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.42"
      configuration_aliases = [
        aws.virginia,
      ]
    }
  }
  required_version = ">= 1.5.2"
}
