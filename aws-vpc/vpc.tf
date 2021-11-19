###################
# VPC
###################
resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
  )
}

###################
# Internet gateway
###################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
  )
}

###################
# NAT gateway
###################
resource "aws_eip" "nat" {
  vpc = true

  tags = merge(
    {
      "Name" = format("%s-nat", var.name)
    },
    var.tags,
  )

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
  )
}

######################
# VPC Endpoint for S3
######################
data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = data.aws_vpc_endpoint_service.s3.service_name
}

resource "aws_vpc_endpoint_route_table_association" "public" {
  route_table_id  = aws_route_table.public.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "private" {
  route_table_id  = aws_route_table.private.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}