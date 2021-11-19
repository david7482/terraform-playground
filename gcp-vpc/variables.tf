variable "name" {
  default = "david74"
}

variable "env" {
  default = ""
}

variable "subnets" {
  type = list(object({
    region = string
    cidr   = string
  }))

  default = []
}