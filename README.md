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
| <a name="input_s3_policy_statements_additional"></a> [s3\_policy\_statements\_additional](#input\_s3\_policy\_statements\_additional) | Additional policies that need to be attached to the S3 bucket. [Detailed](#s3\_policy\_statements\_additional)| `null` | `list(object)`| no |

## s3_policy_statements_additional 

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="statement_sid"></a> [sid](#statement\_sid) | Sid (statement ID) is an identifier for a policy statement. | `string` | `n/a` | yes |
| <a name="statement_principals"></a> [principals](#statement\_principals) | List of configuration objects for principals. [Detailed](#Principals)| `list(object())` | `n/a` | yes |
| <a name="statement_effect"></a> [effect](#statement\_effect) | Whether this statement allows or denies the given actions. Valid values are Allow and Deny. | `string` | `n/a` | yes |
| <a name="statement_actions"></a> [actions](#statement\_actions) | List of actions that this statement either allows or denies. | `list(string)` | `n/a` | yes |
| <a name="statement_resources"></a> [resources](#statement\_resources) | List of resources ARNs that this statement applies to. | `list(string)` | `n/a` | yes |
| <a name="statement_conditions"></a> [conditions](#statement\_conditions) | List of configuration objects for a condition. [Detailed](#Conditions)| `list(object())` | `n/a` | yes |


## Principals

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="principal_type"></a> [type](#principal\_type) | Type of principal. Valid values include `AWS`, `Service`, `Federated`, `CanonicalUser` and `*`. | `string` | `n/a` | yes |
| <a name="principal_identifiers"></a> [identifiers](#principal\_identifiers) | List of identifiers for principals. | `list(string)` | `n/a` | yes |


## Conditions

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="condition_test"></a> [test](#condition\_test) | Name of the IAM condition operator to evaluate. | `string` | `n/a` | yes |
| <a name="condition_variable"></a> [variable](#condition\_variable) | Name of a Context Variable to apply the condition to. Context variables may either be standard AWS variables starting with `aws:` or service-specific variables prefixed with the service name. | `string` | `n/a` | yes |
| <a name="condition_values"></a> [sid](#condition\_values) | List of values to evaluate the condition against. | `list(string)` | `n/a` | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | The S3 bucket identifier |
| <a name="output_cloudfront_distribution_id"></a> [cloudfront\_distribution\_id](#output\_cloudfront\_distribution\_id) | The cloudfront distribution identifier assigned to the S3 bucket |
| <a name="output_ssl_certificate_validation_dns_records"></a> [ssl\_certificate\_validation\_dns\_records](#output\_ssl\_certificate\_validation\_dns\_records) | List of text expressions of the certificate validation DNS records to create this records manually. Required if [create\_dns\_records](#input\_create\_dns\_records) is `false` |
| <a name="output_resource_domain_record"></a> [resource\_domain\_record](#output\_resource\_domain\_record) | Text expressions of the website DNS record to create this records manually. Required if [create\_dns\_records](#input\_create\_dns\_records) is `false` |