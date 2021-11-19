region = "us-east-1"
name   = "david74-vpc"
tags = {
  "Environment" = "internal"
  "Purpose"     = "test"
}
cidr = "10.1.0.0/16"
az_subnets = [
  {
    az           = "us-east-1a"
    public_cidr  = "10.1.0.0/24"
    private_cidr = "10.1.10.0/24"
  },
  {
    az           = "us-east-1b"
    public_cidr  = "10.1.1.0/24"
    private_cidr = "10.1.11.0/24"
  },
  {
    az           = "us-east-1c"
    public_cidr  = "10.1.2.0/24"
    private_cidr = "10.1.12.0/24"
  },
]