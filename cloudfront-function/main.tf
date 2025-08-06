/**
 * Config
 *
 **/

locals {
  cloudfront_function_configs = {
    usage   = var.cloudfront_function_config.usage
    runtime = var.cloudfront_function_config.runtime
    code = (
      var.cloudfront_function_config.usage == "basic_auth" ?
      file("${path.module}/basic_auth.tftpl") :
      var.cloudfront_function_config.code
    )
    basic_auth = {
      username = try(var.cloudfront_function_config.basic_auth.username, null) != null ? var.cloudfront_function_config.basic_auth.username : null
      password = try(var.cloudfront_function_config.basic_auth.password, null) != null ? var.cloudfront_function_config.basic_auth.password : random_password.password[0].result
    }
  }
}

resource "aws_cloudfront_function" "this" {
  publish                      = true
  name                         = var.name
  comment                      = "function for ${var.name}"
  runtime                      = local.cloudfront_function_configs.runtime
  code                         = local.cloudfront_function_configs.code
  key_value_store_associations = local.cloudfront_function_configs.usage == "basic_auth" ? [aws_cloudfront_key_value_store.store[0].arn] : []
}

resource "aws_cloudfront_key_value_store" "this" {
  count   = local.cloudfront_function_configs.usage == "basic_auth" ? 1 : 0
  name    = var.name
  comment = "Key value store for ${var.name} CloudFront function"
}

resource "aws_cloudfrontkeyvaluestore_key" "password" {
  count               = local.cloudfront_function_configs.usage == "basic_auth" ? 1 : 0
  key_value_store_arn = aws_cloudfront_key_value_store.store[0].arn
  key                 = "password"
  value               = local.cloudfront_function_configs.basic_auth.password
}

resource "aws_cloudfrontkeyvaluestore_key" "username" {
  count               = local.cloudfront_function_configs.usage == "basic_auth" ? 1 : 0
  key_value_store_arn = aws_cloudfront_key_value_store.store[0].arn
  key                 = "username"
  value               = local.cloudfront_function_configs.basic_auth.username
}

resource "random_password" "this" {
  count   = try(var.cloudfront_function_config.basic_auth.password, null) == null ? 1 : 0
  length  = 20
  special = false
}
