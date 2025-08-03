output "bucket_id" {
  value = aws_s3_bucket.website.id
}

output "bucket_arn" {
  value = aws_s3_bucket.website.arn
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.website.id
}

output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.website.arn
}

output "resource_domain_record" {
  value = "${var.domain} CNAME ${aws_cloudfront_distribution.website.domain_name}"
}

output "certificate_validation_records" {
  value = [
    for dvo in aws_acm_certificate.website.domain_validation_options : "${dvo.resource_record_name} ${dvo.resource_record_type} ${dvo.resource_record_value}"
  ]
}

output "auth_enabled" {
  value       = var.cloudfront_auth
  description = "Whether basic authentication is enabled"
}

output "auth_username" {
  value       = var.cloudfront_auth ? (var.auth_username != null ? var.auth_username : "admin") : null
  description = "Username for basic authentication"
}

output "auth_password" {
  value       = var.cloudfront_auth ? random_password.auth_password[0].result : null
  description = "Generated password for basic authentication"
  sensitive   = true
}

output "cloudfront_function_arn" {
  value       = var.cloudfront_auth ? aws_cloudfront_function.basic_auth[0].arn : null
  description = "ARN of the CloudFront function for basic authentication"
}

output "website_url" {
  value       = "https://${var.domain}"
  description = "Full URL of the website"
}

output "slack_notification_lambda_arn" {
  value       = var.cloudfront_auth && var.slack_webhook_url != null ? module.notify_slack[0].lambda_function_arn : null
  description = "ARN of the Slack notification Lambda function"
}

output "sns_topic_arn" {
  value       = var.cloudfront_auth && var.slack_webhook_url != null ? aws_sns_topic.auth_notifications[0].arn : null
  description = "ARN of the SNS topic for auth notifications"
}
