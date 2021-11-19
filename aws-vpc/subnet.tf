################
# Public subnet
################
resource "aws_subnet" "public" {
  count = length(var.az_subnets)

  vpc_id                  = aws_vpc.main.id
  availability_zone       = lookup(var.az_subnets[count.index], "az")
  cidr_block              = lookup(var.az_subnets[count.index], "public_cidr")
  map_public_ip_on_launch = true

  tags = {
    Name        = format("%s-public-%s", var.name, lookup(var.az_subnets[count.index], "az"))
    Environment = "internal"
    Purpose     = "public-subnet"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

################
# Private subnet
################
resource "aws_subnet" "private" {
  count = length(var.az_subnets)

  vpc_id                  = aws_vpc.main.id
  availability_zone       = lookup(var.az_subnets[count.index], "az")
  cidr_block              = lookup(var.az_subnets[count.index], "private_cidr")
  map_public_ip_on_launch = false

  tags = {
    Name        = format("%s-private-%s", var.name, lookup(var.az_subnets[count.index], "az"))
    Environment = "internal"
    Purpose     = "private-subnet"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}