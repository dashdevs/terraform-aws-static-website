variable "domain" {
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
  default = []
}
