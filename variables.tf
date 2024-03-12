variable "domain" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "domain_zone_name" {
  type    = string
  default = null
}

variable "create_dns_records" {
  type    = bool
  default = true
}

variable "cors_allowed_origins" {
  type    = list(string)
  default = null
}

variable "cors_allowed_methods_additional" {
  type    = list(string)
  default = null
}

variable "s3_policy_statements_additional" {
  type = list(object({
    sid = string
    principals = list(object({
      type        = string
      identifiers = list(string)
    }))
    effect    = string
    actions   = list(string)
    resources = list(string)
    conditions = list(object({
      test     = string
      variable = string
      values   = list(string)
    }))
  }))
  default  = []
  nullable = false
}

variable "cloudfront_allowed_bucket_resources" {
  type    = list(string)
  default = ["*"]
}
