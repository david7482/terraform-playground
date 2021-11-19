region = "us-west-2"
name   = "david74-vpc"
tags = {
  "Environment" = "internal"
  "Purpose"     = "test"
}
cidr = "10.2.0.0/16"
az_subnets = [
  {
    az           = "us-west-2a"
    public_cidr  = "10.2.0.0/24"
    private_cidr = "10.2.10.0/24"
  },
  {
    az           = "us-west-2b"
    public_cidr  = "10.2.1.0/24"
    private_cidr = "10.2.11.0/24"
  },
  {
    az           = "us-west-2c"
    public_cidr  = "10.2.2.0/24"
    private_cidr = "10.2.12.0/24"
  },
]