# Testing the Static Website Module

This directory contains test configurations for the `terraform-aws-static-website` module.

## Test Files

- `main.tf` - Basic test with authentication enabled
- `main-with-slack.tf` - Test with Slack integration
- `versions.tf` - Terraform configuration and providers

## How to Test

### 1. Basic Test (Authentication Only)

```bash
cd test
terraform init
terraform plan
terraform apply
```

This will create:
- S3 bucket with random suffix
- CloudFront distribution
- Basic authentication with default "admin" username
- Random password generation

### 2. Test with Slack Integration

First, create a `terraform.tfvars` file:

```hcl
slack_webhook_url = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
slack_channel     = "#your-channel"
# slack_username defaults to "CF-Auth-creds"
# slack_emoji defaults to ":lock:"
```

Then run:

```bash
cd test
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

This will additionally create:
- SNS topic for notifications
- Lambda function for Slack integration
- Automatic credential notifications

## Test Outputs

After running the tests, you can check the outputs:

```bash
terraform output
```

Key outputs to verify:
- `test_website_url` - Website URL
- `test_auth_username` - Username (should be "admin" by default)
- `test_auth_password` - Generated password (sensitive)
- `test_cloudfront_function_arn` - CloudFront function ARN

## Cleanup

To destroy the test resources:

```bash
terraform destroy
```

## Notes

- DNS records are disabled (`create_dns_records = false`) to avoid conflicts
- Bucket names include random suffixes to prevent conflicts
- Passwords are generated randomly on each run
- Slack integration is optional and requires a valid webhook URL

## Troubleshooting

1. **Bucket name conflicts**: The random suffix should prevent this
2. **CloudFront function errors**: Check the function code in the main module
3. **Slack notifications not working**: Verify webhook URL and channel permissions
4. **Authentication not working**: Check CloudFront function association in the distribution 