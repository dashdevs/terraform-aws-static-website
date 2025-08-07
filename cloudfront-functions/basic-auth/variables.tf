variable "name" {
  type = string
}

variable "cloudfront_function_config" {
  type = object({
    runtime = string
    credentials = object({
      username = string
      password = string
    })
  })

  default = {
    runtime = "cloudfront-js-2.0"
    credentials = {
      username = null
      password = null
    }
  }
}
