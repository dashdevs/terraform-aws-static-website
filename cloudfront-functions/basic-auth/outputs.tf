output "cloudfront_function_arn" {
  description = "The ARN of the CloudFront function."
  value       = module.composite.cloudfront_function_arn
}

output "key_value_store_arn" {
  description = "The ARN of the key value store holding the basic auth credentials."
  value       = module.composite.key_value_store_arn
}

output "username" {
  description = "The username for basic auth."
  value       = module.composite.username
}

output "password" {
  description = "The password for basic auth."
  value       = module.composite.password
  sensitive   = true
}
