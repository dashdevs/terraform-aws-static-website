locals {
  runtime  = var.runtime
  password = var.password != null ? var.password : random_password.this[0].result
}

resource "aws_cloudfront_function" "this" {
  publish                      = true
  name                         = var.name
  comment                      = "function for ${var.name}"
  runtime                      = local.runtime
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
  value               = local.password
}

resource "aws_cloudfrontkeyvaluestore_key" "username" {
  key_value_store_arn = aws_cloudfront_key_value_store.this.arn
  key                 = "username"
  value               = var.username
}

resource "random_password" "this" {
  count   = try(var.password, null) == null ? 1 : 0
  length  = 20
  special = false
}
