# terraform-aws-static-website


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
| <a name="input_domain"></a> [domain](#input\_domain) | Domain name for the site | `string` | `n/a` | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name for the S3 bucket | `string` | `n/a` | yes |
| <a name="input_domain_zone_name"></a> [domain\_zone\_name](#input\_domain\_zone\_name) | The name of the domain zone in the route53 service for which DNS records will be created. Must be set if create_dns_records is `true` | `string` | `null` | no |
| <a name="input_create_dns_records"></a> [create\_dns\_records](#input\_create\_dns\_records) | If true, then DNS records are created in route53 for this site and connected to the cloudfront distribution | `bool` |`true`| no |
| <a name="input_cors_allowed_origins"></a> [cors\_allowed\_origins](#input\_cors\_allowed\_origins) | Used to declare domains from which the site will be accessed as a storage of static resources | `null` |`list(string)`| no |
| <a name="input_s3_policy_statements_additional"></a> [s3\_policy\_statements\_additional](#input\_s3\_policy\_statements\_additional) | Additional policy [statments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement)  that need to be attached to the S3 bucket. | <pre>list(object({<br>  sid        = string<br>  principals = list(objec({<br>    type        = string<br>    identifiers = list(string)<br>  }))<br>  effect     = string<br>  actions    = list(string)<br>  resources  = list(string)<br>  conditions = list(object({<br>    test     = string<br>    variable = string<br>    values   = list(string)<br>  }))<br>}))</pre> | `null` | no |


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | The S3 bucket identifier |
| <a name="output_cloudfront_distribution_id"></a> [cloudfront\_distribution\_id](#output\_cloudfront\_distribution\_id) | The cloudfront distribution identifier assigned to the S3 bucket |
| <a name="output_ssl_certificate_validation_dns_records"></a> [ssl\_certificate\_validation\_dns\_records](#output\_ssl\_certificate\_validation\_dns\_records) | List of text expressions of the certificate validation DNS records to create this records manually. Required if [create\_dns\_records](#input\_create\_dns\_records) is `false` |
| <a name="output_resource_domain_record"></a> [resource\_domain\_record](#output\_resource\_domain\_record) | Text expressions of the website DNS record to create this records manually. Required if [create\_dns\_records](#input\_create\_dns\_records) is `false` |