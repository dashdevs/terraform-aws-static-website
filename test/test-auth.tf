# Test configuration for the static website module with authentication
# This file can be used to test the module locally

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.34"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Test module with authentication enabled
module "test_website" {
  source = "."

  bucket_name        = "test-website-${random_id.bucket_suffix.hex}"
  domain             = "test.example.com"
  domain_zone_name   = "example.com"
  create_dns_records = false  # Set to false for testing without DNS
  
  # Enable authentication
  cloudfront_auth    = true
  # auth_username defaults to "admin" when cloudfront_auth is true
  
  # Slack integration (optional for testing)
  # slack_webhook_url  = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
  # slack_channel      = "#test"
}

# Random suffix for bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Outputs for testing
output "test_website_url" {
  value = module.test_website.website_url
}

output "test_auth_enabled" {
  value = module.test_website.auth_enabled
}

output "test_auth_username" {
  value = module.test_website.auth_username
}

output "test_auth_password" {
  value     = module.test_website.auth_password
  sensitive = true
}

output "test_cloudfront_function_arn" {
  value = module.test_website.cloudfront_function_arn
} 