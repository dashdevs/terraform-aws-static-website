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
  type     = list(string)
  default  = []
  nullable = false
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

variable "redirect_to" {
  type    = string
  default = null
}

variable "cloudfront_auth" {
  type        = bool
  default     = false
  description = "Enable CloudFront Basic Auth with password rotation"
}

variable "slack_webhook_url" {
  type        = string
  default     = null
  description = "Slack webhook URL for sending auth credentials"
}

variable "slack_channel" {
  type        = string
  default     = "#infrastructure"
  description = "Slack channel to send auth credentials to"
}

variable "slack_username" {
  type        = string
  default     = "CF-Auth-Сreds"
  description = "Slack username for notifications"
}

variable "slack_emoji" {
  type        = string
  default     = ":lock:"
  description = "Slack emoji for notifications"
}

variable "auth_username" {
  type        = string
  default     = null
  description = "Username for basic authentication (defaults to 'admin' when cloudfront_auth is true)"
}
