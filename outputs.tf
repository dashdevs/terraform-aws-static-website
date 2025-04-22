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
