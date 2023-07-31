variable "private_subnets" {
  type = map(any)
  default = {
    a = "10.0.0.0/20"
    b = "10.0.16.0/20"
    c = "10.0.32.0/20"
    d = "10.0.48.0/20"
  }
}

variable "public_subnets" {
  type = map(any)
  default = {
    a = "10.0.64.0/20"
    b = "10.0.80.0/20"
    c = "10.0.96.0/20"
    d = "10.0.112.0/20"
  }
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

