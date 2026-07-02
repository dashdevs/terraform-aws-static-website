output "cloudfront_function_arn" {
  description = "The ARN of the CloudFront function."
  value       = aws_cloudfront_function.this.arn
}

output "key_value_store_arn" {
  description = "The ARN of the key value store associated with the function, if any."
  value       = var.enable_basic_auth ? aws_cloudfront_key_value_store.this[0].arn : null
}

output "username" {
  description = "The username for basic auth, null when basic auth is disabled."
  value       = var.enable_basic_auth ? aws_cloudfrontkeyvaluestore_key.username[0].value : null
}

output "password" {
  description = "The password for basic auth, null when basic auth is disabled."
  value       = var.enable_basic_auth ? local.password : null
  sensitive   = true
}
