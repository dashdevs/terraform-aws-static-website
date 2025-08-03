# Test configuration with Slack integration
# Uncomment and modify the variables below to test Slack notifications

# Test module with authentication and Slack integration
module "test_website_with_slack" {
  source = "../"

  bucket_name        = "test-website-slack-${random_id.bucket_suffix.hex}"
  domain             = "test-slack.example.com"
  domain_zone_name   = "example.com"
  create_dns_records = false  # Set to false for testing without DNS
  
  # Enable authentication
  cloudfront_auth    = true
  auth_username      = "testuser"  # Custom username
  
  # Slack integration
  slack_webhook_url  = var.slack_webhook_url
  slack_channel      = var.slack_channel
  slack_username     = var.slack_username
  slack_emoji        = var.slack_emoji
}

# Variables for Slack configuration
variable "slack_webhook_url" {
  type        = string
  description = "Slack webhook URL for testing"
  default     = null
}

variable "slack_channel" {
  type        = string
  description = "Slack channel for testing"
  default     = "#test"
}

variable "slack_username" {
  type        = string
  description = "Slack username for testing"
  default     = "CF-Auth-Сreds"
}

variable "slack_emoji" {
  type        = string
  description = "Slack emoji for testing"
  default     = ":lock:"
}

# Outputs for Slack testing
output "test_slack_website_url" {
  value = module.test_website_with_slack.website_url
}

output "test_slack_auth_username" {
  value = module.test_website_with_slack.auth_username
}

output "test_slack_auth_password" {
  value     = module.test_website_with_slack.auth_password
  sensitive = true
}

output "test_slack_notification_lambda_arn" {
  value = module.test_website_with_slack.slack_notification_lambda_arn
}

output "test_slack_sns_topic_arn" {
  value = module.test_website_with_slack.sns_topic_arn
} 