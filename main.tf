/**
 * Config
 *
 **/

locals {
  s3_origin_id         = "websiteorigin"
  s3_root_object       = "index.html"
  cors_allowed_origins = var.cors_allowed_origins != [] ? var.cors_allowed_origins : ["https://${var.domain}"]
}

data "aws_route53_zone" "public_zone" {
  count        = var.create_dns_records ? 1 : 0
  name         = var.domain_zone_name
  private_zone = false
}


/**
 * Certificate
 *
 **/

# To use an ACM certificate with CloudFront, make sure you request (or import) the certificate in the US East (N. Virginia)
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

resource "aws_acm_certificate" "website" {
  provider = aws.virginia

  domain_name       = var.domain
  validation_method = "DNS"
}

resource "aws_route53_record" "website_certificate_validation_records" {
  provider = aws.virginia

  for_each = {
    for dvo in var.create_dns_records ? aws_acm_certificate.cerificate.domain_validation_options : [] : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.public_zone[0].zone_id
}

resource "aws_acm_certificate_validation" "website_certificate_validation" {
  provider = aws.virginia

  certificate_arn         = aws_acm_certificate.website.arn
  validation_record_fqdns = [for record in aws_route53_record.website_certificate_validation_records : record.fqdn]
}


/**
 * DNS Record
 *
 **/

resource "aws_route53_record" "a" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.public_zone[0].zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}


/**
 * S3 Bucket
 *
 **/

resource "aws_s3_bucket" "website" {
  bucket = var.domain
}

resource "aws_s3_bucket_cors_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = local.cors_allowed_origins
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document { suffix = local.s3_root_object }
  error_document { key = local.s3_root_object }
}


/**
 * CloudFront Distribution
 *
 **/

resource "aws_cloudfront_origin_access_identity" "website" {
  comment = var.domain
}

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  aliases             = [var.domain]
  comment             = var.domain
  default_root_object = local.s3_root_object
  price_class         = "PriceClass_All"

  origin {
    domain_name = aws_s3_bucket.website.bucket_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  custom_error_response {
    error_caching_min_ttl = 86400
    error_code            = 404
    response_code         = 200
    response_page_path    = "/${local.s3_root_object}"
  }

  custom_error_response {
    error_caching_min_ttl = 86400
    error_code            = 403
    response_code         = 200
    response_page_path    = "/${local.s3_root_object}"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 60
    default_ttl            = 3600
    max_ttl                = 86400

    response_headers_policy_id = aws_cloudfront_response_headers_policy.website_security.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.website.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_response_headers_policy" "website_security" {
  name = replace(var.domain, ".", "-")

  custom_headers_config {
    items {
      header   = "X-Permitted-Cross-Domain-Policies"
      value    = "none"
      override = true
    }
    items {
      header   = "Feature-Policy"
      value    = "camera 'none'; fullscreen 'self'; geolocation *; microphone 'self' https://${var.domain}/*"
      override = true
    }
  }

  security_headers_config {
    content_security_policy {
      content_security_policy = "default-src * blob: data:; script-src https: 'unsafe-inline' 'unsafe-eval'; style-src https: 'unsafe-inline'"
      override                = true
    }
    content_type_options {
      override = true
    }
    referrer_policy {
      referrer_policy = "no-referrer-when-downgrade"
      override        = true
    }
    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }
    strict_transport_security {
      access_control_max_age_sec = "31536000"
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
  }
}


/**
 * S3 Bucket IAM
 *
 **/

data "aws_iam_policy_document" "allow_website_cloudfront" {
  statement {
    sid = "Allow bucket access from CloudFront"

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.website.iam_arn]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.allow_website_cloudfront.json
}