output "cloudfront_function_arn" {
  description = "The ARN of the CloudFront function."
  value       = aws_cloudfront_function.this.arn
}

output "key_value_store_arn" {
  description = "The ARN of the key value store holding the basic auth credentials."
  value       = aws_cloudfront_key_value_store.this.arn
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
