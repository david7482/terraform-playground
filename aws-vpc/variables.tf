variable "aws_profile" {
  default = "david74"
}

variable "region" {
  default = ""
}

variable "name" {
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "cidr" {
  default = "0.0.0.0/0"
}

variable "az_subnets" {
  type = list(object({
    az           = string
    public_cidr  = string
    private_cidr = string
  }))

  default = []
}