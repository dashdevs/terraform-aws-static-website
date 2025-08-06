variable "name" {
  type = string
}

variable "cloudfront_function_config" {
  type = object({
    runtime = string
    usage   = string
    code    = string
    basic_auth = optional(object({
      username = string
      password = string
    }), null)
  })

  default = {
    runtime = "cloudfront-js-2.0"
    usage   = "basic_auth"
    code    = "basic_auth"
    basic_auth = {
      username = null
      password = null
    }
  }

  validation {
    condition     = contains(["basic_auth", "custom"], var.cloudfront_function_config.usage)
    error_message = "The usage value must be either \"basic_auth\" or \"custom\"."
  }
}
