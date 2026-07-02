locals {
  password = var.password != null ? var.password : try(random_password.this[0].result, null)
}

resource "aws_cloudfront_function" "this" {
  publish = true
  name    = var.name
  comment = "function for ${var.name}"
  runtime = "cloudfront-js-2.0"
  code = templatefile("${path.module}/function.tftpl", {
    enable_basic_auth      = var.enable_basic_auth
    enable_directory_index = var.enable_directory_index
  })
  key_value_store_associations = var.enable_basic_auth ? [aws_cloudfront_key_value_store.this[0].arn] : []

  lifecycle {
    precondition {
      condition     = var.enable_basic_auth || var.enable_directory_index
      error_message = "At least one of enable_basic_auth or enable_directory_index must be true."
    }
  }
}

resource "aws_cloudfront_key_value_store" "this" {
  count   = var.enable_basic_auth ? 1 : 0
  name    = var.name
  comment = "Key value store for ${var.name} CloudFront function"
}

resource "aws_cloudfrontkeyvaluestore_key" "username" {
  count               = var.enable_basic_auth ? 1 : 0
  key_value_store_arn = aws_cloudfront_key_value_store.this[0].arn
  key                 = "username"
  value               = var.username
}

resource "aws_cloudfrontkeyvaluestore_key" "password" {
  count               = var.enable_basic_auth ? 1 : 0
  key_value_store_arn = aws_cloudfront_key_value_store.this[0].arn
  key                 = "password"
  value               = local.password
}

resource "random_password" "this" {
  count   = var.enable_basic_auth && var.password == null ? 1 : 0
  length  = 20
  special = false
}
