variable "name" {
  type = string
}

variable "enable_basic_auth" {
  type    = bool
  default = false
}

variable "enable_directory_index" {
  type    = bool
  default = false
}

variable "username" {
  type    = string
  default = "admin"
}

variable "password" {
  type    = string
  default = null
}
