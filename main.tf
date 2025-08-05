/**
 * Config
 *
 **/

locals {
  s3_origin_id         = "websiteorigin"
  s3_root_object       = "index.html"
  cors_allowed_default = ["GET", "HEAD"]

  create_cors_configuration = var.cors_allowed_origins != null
  create_redirect           = var.redirect_to != null

  cors_allowed_methods                = concat(local.cors_allowed_default, var.cors_allowed_methods_additional)
  cloudfront_allowed_bucket_resources = [for resource in var.cloudfront_allowed_bucket_resources : "${aws_s3_bucket.website.arn}/${resource}"]
}

check "application_repository_validation" {
  assert {
    condition     = !(var.create_dns_records && var.domain_zone_name == null)
    error_message = "If create_dns_records is true then domain_zone_name must be set!"
  }
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
    for dvo in var.create_dns_records ? aws_acm_certificate.website.domain_validation_options : [] : dvo.domain_name => {
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
  count    = var.create_dns_records ? 1 : 0
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
  bucket = var.bucket_name
}

resource "aws_s3_bucket_cors_configuration" "website" {
  count  = local.create_cors_configuration ? 1 : 0
  bucket = aws_s3_bucket.website.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = local.cors_allowed_methods
    allowed_origins = var.cors_allowed_origins
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  count  = local.create_redirect ? 0 : 1
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = local.s3_root_object
  }

  error_document {
    key = local.s3_root_object
  }
}

resource "aws_s3_bucket_website_configuration" "redirect" {
  count  = local.create_redirect ? 1 : 0
  bucket = aws_s3_bucket.website.id

  redirect_all_requests_to {
    host_name = var.redirect_to
    protocol  = "https"
  }
}


/**
 * CloudFront Distribution
 *
 **/

locals {
  custom_error_responses = local.create_redirect ? [] : [
    {
      error_caching_min_ttl = 86400
      error_code            = 404
      response_code         = 200
      response_page_path    = "/${local.s3_root_object}"
    },
    {
      error_caching_min_ttl = 86400
      error_code            = 403
      response_code         = 200
      response_page_path    = "/${local.s3_root_object}"
    }
  ]
}

resource "aws_cloudfront_origin_access_control" "website" {
  name                              = var.domain
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  aliases             = [var.domain]
  comment             = var.domain
  default_root_object = local.s3_root_object
  price_class         = "PriceClass_All"

  origin {
    domain_name = (local.create_redirect ?
      aws_s3_bucket_website_configuration.redirect[0].website_endpoint :
      aws_s3_bucket.website.bucket_regional_domain_name
    )

    origin_access_control_id = local.create_redirect ? null : aws_cloudfront_origin_access_control.website.id
    origin_id                = local.s3_origin_id

    dynamic "custom_origin_config" {
      for_each = local.create_redirect ? [1] : []
      content {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = local.custom_error_responses
    content {
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    cache_policy_id            = aws_cloudfront_cache_policy.default.id
    response_headers_policy_id = local.create_redirect ? null : aws_cloudfront_response_headers_policy.website_security[0].id
    viewer_protocol_policy     = local.create_redirect ? "allow-all" : "redirect-to-https"
    dynamic "function_association" {
      for_each = var.cloudfront_function_config.arn != null ? [1] : []
      content {
        event_type   = var.cloudfront_function_config.event_type
        function_arn = var.cloudfront_function_config.arn
      }
    }
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

resource "aws_cloudfront_cache_policy" "default" {
  name = replace(var.domain, ".", "-")

  min_ttl     = 60
  default_ttl = 3600
  max_ttl     = 86400

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config { cookie_behavior = "none" }
    headers_config { header_behavior = "none" }
    query_strings_config { query_string_behavior = "none" }
  }
}

resource "aws_cloudfront_response_headers_policy" "website_security" {
  count = local.create_redirect ? 0 : 1
  name  = replace(var.domain, ".", "-")

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

locals {
  s3_bucket_policy_statements = (local.create_redirect ?
    var.s3_policy_statements_additional :
    concat([{
      sid = "Allow bucket access from CloudFront using OAC"

      principals = [{
        type        = "Service"
        identifiers = ["cloudfront.amazonaws.com"]
      }]

      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = local.cloudfront_allowed_bucket_resources

      conditions = [{
        test     = "StringEquals"
        variable = "AWS:SourceArn"
        values   = [aws_cloudfront_distribution.website.arn]
      }]
    }], var.s3_policy_statements_additional)
  )
  create_s3_bucket_policy = length(local.s3_bucket_policy_statements) > 0
}

data "aws_iam_policy_document" "allow_website_cloudfront" {
  count = local.create_s3_bucket_policy ? 1 : 0
  dynamic "statement" {
    for_each = local.s3_bucket_policy_statements

    content {
      sid = statement.value["sid"]
      dynamic "principals" {
        for_each = statement.value["principals"]

        content {
          type        = principals.value["type"]
          identifiers = principals.value["identifiers"]
        }
      }
      effect    = statement.value["effect"]
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
      dynamic "condition" {
        for_each = statement.value["conditions"]

        content {
          test     = condition.value["test"]
          variable = condition.value["variable"]
          values   = condition.value["values"]
        }
      }
    }
  }
}

resource "aws_s3_bucket_policy" "allow_cloudfront" {
  count  = local.create_s3_bucket_policy ? 1 : 0
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.allow_website_cloudfront[0].json
}
