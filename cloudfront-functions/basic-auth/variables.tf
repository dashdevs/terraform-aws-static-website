variable "name" {
  type = string
}

variable "runtime" {
  type    = string
  default = "cloudfront-js-2.0"
}

variable "username" {
  type    = string
  default = "admin"
}

variable "password" {
  type    = string
  default = null
}
