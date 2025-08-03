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

### With Basic Authentication and Slack notifications:
```
module "website" {
  source             = "dashdevs/static-website/aws"
  bucket_name        = var.bucket_name
  domain             = var.domain
  domain_zone_name   = var.domain_zone_name
  create_dns_records = true
  
  # Enable CloudFront Basic Auth
  cloudfront_auth    = true
  
  # Slack integration for credential notifications
  slack_webhook_url  = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
  slack_channel      = "#infrastructure"
}
```

**Note:** When `cloudfront_auth = true` is enabled:
- A random password is generated on each Terraform run
- Username defaults to "admin" if not specified
- New credentials are automatically sent to the specified Slack channel
- The CloudFront function performs Basic Authentication at the edge
- Password rotation ensures security compliance

## CloudFront Basic Authentication

This module supports basic authentication through CloudFront Functions with automatic password rotation and Slack integration.

### Features
- ✅ **CloudFront Functions**: Uses CloudFront Functions (NOT Lambda) for authentication
- ✅ **Automatic Password Rotation**: New password is generated on each Terraform run
- ✅ **Slack Integration**: Automatic sending of new credentials to Slack
- ✅ **Security**: Passwords are stored as sensitive outputs
- ✅ **Flexibility**: Can be enabled/disabled via the `cloudfront_auth` parameter

### Security
- Passwords are randomly generated with 16 characters
- Passwords contain uppercase, lowercase, numbers, and special characters
- Passwords are rotated on each Terraform run
- All passwords are marked as `sensitive` in Terraform outputs

### Slack Notifications
When Slack integration is enabled, the message contains:
- Website URL
- Username
- New password
- Generation timestamp

### Limitations
- CloudFront Functions have a 10KB code limit
- Function executes on every request (viewer-request)
- Passwords are stored in function code (encrypted in CloudFront)
- Slack webhook URL must be valid


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
| <a name="input_cors_allowed_origins"></a> [cors\_allowed\_origins](#input\_cors\_allowed\_origins) | Used to declare domains from which the site will be accessed as a storage of static resources | `list(string)` |`null`| no |
| <a name="input_cors_allowed_methods_additional"></a> [cors\_allowed\_methods\_additional](#input\_cors\_allowed\_methods\_additional) | Additional HTTP methods to be allowed in the CORS configuration for the S3 bucket (e.g., POST, PUT). | `list(string)` | `[]` | no |
| <a name="input_s3_policy_statements_additional"></a> [s3\_policy\_statements\_additional](#input\_s3\_policy\_statements\_additional) | Additional policy [statments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement)  that need to be attached to the S3 bucket. | <pre>list(object({<br>  sid        = string<br>  principals = list(objec({<br>    type        = string<br>    identifiers = list(string)<br>  }))<br>  effect     = string<br>  actions    = list(string)<br>  resources  = list(string)<br>  conditions = list(object({<br>    test     = string<br>    variable = string<br>    values   = list(string)<br>  }))<br>}))</pre> | `[]` | no |
| <a name="input_cloudfront_allowed_bucket_resources"></a> [cloudfront\_allowed\_bucket\_resources](#input\_cloudfront\_allowed\_bucket\_resources) | List of resources that the Cloudfront is allowed to access.  | `list(string)` |`["*"]`| no |
| <a name="input_redirect_to"></a> [redirect\_to](#input\_redirect\_to) | Target domain for redirecting all requests, enforced with HTTPS. | `string` |`null`| no |
| <a name="input_cloudfront_auth"></a> [cloudfront\_auth](#input\_cloudfront\_auth) | Enable CloudFront Basic Auth with password rotation | `bool` |`false`| no |
| <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url) | Slack webhook URL for sending auth credentials | `string` |`null`| no |
| <a name="input_slack_channel"></a> [slack\_channel](#input\_slack\_channel) | Slack channel to send auth credentials to | `string` |`#infrastructure`| no |
| <a name="input_slack_username"></a> [slack\_username](#input\_slack\_username) | Slack username for notifications | `string` |`CF-Auth-Сreds`| no |
| <a name="input_slack_emoji"></a> [slack\_emoji](#input\_slack\_emoji) | Slack emoji for notifications | `string` |`:lock:`| no |
| <a name="input_auth_username"></a> [auth\_username](#input\_auth\_username) | Username for basic authentication (defaults to "admin" when cloudfront_auth is true) | `string` |`null`| no |


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Name of the S3 bucket used for website hosting |
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN of the S3 bucket used for website hosting |
| <a name="output_cloudfront_distribution_id"></a> [cloudfront\_distribution\_id](#output\_cloudfront\_distribution\_id) | ID of the CloudFront distribution serving the website |
| <a name="output_cloudfront_distribution_arn"></a> [cloudfront\_distribution\_arn](#output\_cloudfront\_distribution\_arn) | ARN of the CloudFront distribution serving the website |
| <a name="output_ssl_certificate_validation_dns_records"></a> [ssl\_certificate\_validation\_dns\_records](#output\_ssl\_certificate\_validation\_dns\_records) | List of text expressions of the certificate validation DNS records to create this records manually. Required if [create\_dns\_records](#input\_create\_dns\_records) is `false` |
| <a name="output_resource_domain_record"></a> [resource\_domain\_record](#output\_resource\_domain\_record) | Text expressions of the website DNS record to create this records manually. Required if [create\_dns\_records](#input\_create\_dns\_records) is `false` |
| <a name="output_auth_enabled"></a> [auth\_enabled](#output\_auth\_enabled) | Whether basic authentication is enabled |
| <a name="output_auth_username"></a> [auth\_username](#output\_auth\_username) | Username for basic authentication |
| <a name="output_auth_password"></a> [auth\_password](#output\_auth\_password) | Generated password for basic authentication (sensitive) |
| <a name="output_cloudfront_function_arn"></a> [cloudfront\_function\_arn](#output\_cloudfront\_function\_arn) | ARN of the CloudFront function for basic authentication |
| <a name="output_website_url"></a> [website\_url](#output\_website\_url) | Full URL of the website |
| <a name="output_slack_notification_lambda_arn"></a> [slack\_notification\_lambda\_arn](#output\_slack\_notification\_lambda\_arn) | ARN of the Slack notification Lambda function |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | ARN of the SNS topic for auth notifications |