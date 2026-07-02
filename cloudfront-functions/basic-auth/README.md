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
  name               = var.name
  name_zone_name     = var.name_zone_name
  create_dns_records = true
  cloudfront_event_functions = {
    viewer-request  = module.cloudfront_function_basic_auth.cloudfront_function_arn
    viewer-response = module.cloudfront_function_test.cloudfront_function_arn
  }
}

module "cloudfront_function" {
  source = "dashdevs/static-website/aws/cloudfront-functions/basic-auth"
  name   = "example"
  username = "admin"
}

```


<!-- markdownlint-restore -->
<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.35 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.35 |


## Inputs

| Name      | Description                           | Type   | Default              | Required |
|-----------|---------------------------------------|--------|----------------------|:--------:|
| `name`    | The name of the CloudFront function.  | string | n/a                  | ✅       |
| `username`| Username used for basic auth.         | string | `"admin"`            | ❌       |
| `password`| Password used for basic auth.         | string | `null`               | ❌       |

---

## Outputs

| Name                      | Description                                | Sensitive |
|---------------------------|--------------------------------------------|:---------:|
| `cloudfront_function_arn`| The ARN of the CloudFront function.         | ❌        |
| `key_value_store_arn`    | The ARN of the key value store holding the basic auth credentials. | ❌ |
| `username`               | The username for basic auth.               | ❌        |
| `password`               | The password for basic auth.               | ✅        |

---

## Notes

- If `password` is not provided, it should be generated or handled securely within the module logic.
- `username` is stored using AWS KeyValueStore (or similar mechanism), and is exposed as an output.
- Always treat the `password` output as **sensitive**—do not log or expose it.
