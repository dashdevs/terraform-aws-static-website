output "cloudfront_function_arn" {
  description = "The ARN of the CloudFront function."
  value       = aws_cloudfront_function.function.arn
}
