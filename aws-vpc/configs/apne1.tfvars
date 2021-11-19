region = "ap-northeast-1"
name   = "david74-vpc"
tags = {
  "Environment" = "internal"
  "Purpose"     = "test"
}
cidr = "10.0.0.0/16"
az_subnets = [
  {
    az           = "ap-northeast-1a"
    public_cidr  = "10.0.0.0/24"
    private_cidr = "10.0.10.0/24"
  },
  {
    az           = "ap-northeast-1c"
    public_cidr  = "10.0.1.0/24"
    private_cidr = "10.0.11.0/24"
  },
]