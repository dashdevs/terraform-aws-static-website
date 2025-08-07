output "cloudfront_function_arn" {
  description = "The ARN of the CloudFront function."
  value       = aws_cloudfront_function.this.arn
}

output "basic_auth_credentials" {
  description = "Basic auth credentials for the CloudFront function."
  value = {
    username = local.cloudfront_function_configs.credentials.username
    password = local.cloudfront_function_configs.credentials.password
  }
  sensitive = true
}
