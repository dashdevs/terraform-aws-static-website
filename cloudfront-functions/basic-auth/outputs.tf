output "cloudfront_function_arn" {
  description = "The ARN of the CloudFront function."
  value       = aws_cloudfront_function.this.arn
}
output "username" {
  description = "The username for basic auth."
  value       = aws_cloudfrontkeyvaluestore_key.username.value
}

output "password" {
  description = "The password for basic auth."
  value       = local.password
  sensitive   = true
}
