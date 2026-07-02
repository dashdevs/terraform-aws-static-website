module "composite" {
  source            = "../composite"
  name              = var.name
  enable_basic_auth = true
  username          = var.username
  password          = var.password
}

# migrate consumer state from releases <= 3.2,
# where these resources lived in this module directly
moved {
  from = aws_cloudfront_function.this
  to   = module.composite.aws_cloudfront_function.this
}

moved {
  from = aws_cloudfront_key_value_store.this
  to   = module.composite.aws_cloudfront_key_value_store.this[0]
}

moved {
  from = aws_cloudfrontkeyvaluestore_key.username
  to   = module.composite.aws_cloudfrontkeyvaluestore_key.username[0]
}

moved {
  from = aws_cloudfrontkeyvaluestore_key.password
  to   = module.composite.aws_cloudfrontkeyvaluestore_key.password[0]
}

moved {
  from = random_password.this
  to   = module.composite.random_password.this
}
