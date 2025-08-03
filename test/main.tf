# Test configuration for the static website module
# This file demonstrates how to use the module with authentication

# Random suffix for bucket name to avoid conflicts
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Test module with authentication enabled
module "test_website" {
  source = "../"

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
  # slack_username     = "terraform-bot"
  # slack_emoji        = ":lock:"
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

output "test_slack_notification_lambda_arn" {
  value = module.test_website.slack_notification_lambda_arn
}

output "test_sns_topic_arn" {
  value = module.test_website.sns_topic_arn
} 