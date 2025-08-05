# terraform-aws-static-website/cloudfront-function


## Usage


**IMPORTANT:** We do not pin modules to versions in our examples because of the
difficulty of keeping the versions in the documentation in sync with the latest released versions.
We highly recommend that in your code you pin the version to the exact version you are
using so that your infrastructure remains stable, and update versions in a
systematic way so that they do not catch you by surprise.

### example usage for website module:
```
module "website" {
  source             = "dashdevs/static-website/aws"
  bucket_name        = var.bucket_name
  domain             = var.domain
  domain_zone_name   = var.domain_zone_name
  create_dns_records = true
  cloudfront_function_config = {
    event_type = "viewer-request"
    arn        = module.cloudfront_function.cloudfront_function_arn
  }
}

module "cloudfront_function" {
  source             = "dashdevs/static-website/aws//cloudfront-function"
  domain = var.domain_name
  cloudfront_function_config = {
    runtime = "cloudfront-js-2.0"
    usage   = "basic_auth"
    code    = "basic_auth"
    basic_auth = {
      username = "admin"
      password = null
    }
  }
}

```


<!-- markdownlint-restore -->
<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.34 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `domain` | The domain name to be used. | `string` | n/a | ✅ |
| `cloudfront_function_config` | Configuration object for the CloudFront function. | <pre>object({<br>  runtime   = string<br>  usage     = string<br>  code      = string<br>  basic_auth = optional(object({<br>    username = string<br>    password = string<br>  }), null)<br>})</pre> | <pre>{<br>  runtime = "cloudfront-js-2.0"<br>  usage   = "basic_auth"<br>  code    = "basic_auth"<br>  basic_auth = {<br>    username = null<br>    password = null<br>  }<br>}</pre> | ❌ |


## Outputs

| Name | Description |
|------|-------------|
| `cloudfront_function_arn` | The ARN of the CloudFront function. |