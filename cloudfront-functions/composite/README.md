# terraform-aws-static-website/cloudfront-functions/composite

Composite CloudFront viewer-request function. The function code is rendered from a
template with feature flags, so a single function can combine several behaviors:

- `enable_basic_auth` – HTTP basic auth with credentials read from a CloudFront KeyValueStore
- `enable_directory_index` – directory index handling for non-SPA websites: appends `index.html`
  to `/`-terminated paths and 301-redirects extensionless paths to a trailing slash

## Usage

**IMPORTANT:** We do not pin modules to versions in our examples because of the
difficulty of keeping the versions in the documentation in sync with the latest released versions.
We highly recommend that in your code you pin the version to the exact version you are
using so that your infrastructure remains stable, and update versions in a
systematic way so that they do not catch you by surprise.

### directory index only:
```
module "cloudfront_function_directory_index" {
  source                 = "dashdevs/static-website/aws//cloudfront-functions/composite"
  name                   = "example-directory-index"
  enable_directory_index = true
}
```

### basic auth combined with directory index:
```
module "cloudfront_function_composite" {
  source                 = "dashdevs/static-website/aws//cloudfront-functions/composite"
  name                   = "example-composite"
  enable_basic_auth      = true
  enable_directory_index = true
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
| <a name="provider_random"></a> [random](#provider\_random) | n/a |


## Inputs

| Name                     | Description                            | Type   | Default   | Required |
|--------------------------|----------------------------------------|--------|-----------|:--------:|
| `name`                   | The name of the CloudFront function.   | string | n/a       | ✅       |
| `enable_basic_auth`      | Include the basic auth behavior.       | bool   | `false`   | ❌       |
| `enable_directory_index` | Include the directory index behavior.  | bool   | `false`   | ❌       |
| `username`               | Username used for basic auth.          | string | `"admin"` | ❌       |
| `password`               | Password used for basic auth.          | string | `null`    | ❌       |

---

## Outputs

| Name                      | Description                                                           | Sensitive |
|---------------------------|-----------------------------------------------------------------------|:---------:|
| `cloudfront_function_arn` | The ARN of the CloudFront function.                                   | ❌        |
| `key_value_store_arn`     | The ARN of the key value store associated with the function, if any.  | ❌        |
| `username`                | The username for basic auth, null when basic auth is disabled.        | ❌        |
| `password`                | The password for basic auth, null when basic auth is disabled.        | ✅        |

---

## Notes

- At least one of `enable_basic_auth` / `enable_directory_index` must be true.
- When `enable_basic_auth = true`, the module creates a key value store with `username` and
  `password` keys (`password` generated unless provided).
