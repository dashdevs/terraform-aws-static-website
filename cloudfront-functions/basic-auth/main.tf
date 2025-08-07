/**
 * Config
 *
 **/

locals {
  cloudfront_function_configs = {
    runtime = var.cloudfront_function_config.runtime
    credentials = {
      username = try(var.cloudfront_function_config.credentials.username, null) != null ? var.cloudfront_function_config.credentials.username : null
      password = try(var.cloudfront_function_config.credentials.password, null) != null ? var.cloudfront_function_config.credentials.password : random_password.this[0].result
    }
  }
}

resource "aws_cloudfront_function" "this" {
  publish                      = true
  name                         = var.name
  comment                      = "function for ${var.name}"
  runtime                      = local.cloudfront_function_configs.runtime
  code                         = file("${path.module}/function.tftpl")
  key_value_store_associations = [aws_cloudfront_key_value_store.this.arn]
}

resource "aws_cloudfront_key_value_store" "this" {
  name    = var.name
  comment = "Key value store for ${var.name} CloudFront function"
}

resource "aws_cloudfrontkeyvaluestore_key" "password" {
  key_value_store_arn = aws_cloudfront_key_value_store.this.arn
  key                 = "password"
  value               = local.cloudfront_function_configs.credentials.password
}

resource "aws_cloudfrontkeyvaluestore_key" "username" {
  key_value_store_arn = aws_cloudfront_key_value_store.this.arn
  key                 = "username"
  value               = local.cloudfront_function_configs.credentials.username
}

resource "random_password" "this" {
  count   = try(var.cloudfront_function_config.credentials.password, null) == null ? 1 : 0
  length  = 20
  special = false
}
