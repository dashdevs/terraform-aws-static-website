output "cloudfront_function_arn" {
  description = "The ARN of the CloudFront function."
  value       = aws_cloudfront_function.function.arn
}

output "basic_auth_credentials" {
  description = "Basic auth credentials for the CloudFront function."
  value = {
    username = local.cloudfront_function_configs.basic_auth.username
    password = local.cloudfront_function_configs.basic_auth.password
  }
  sensitive = true
}
