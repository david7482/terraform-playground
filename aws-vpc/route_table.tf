########################
# Default route tables
########################
resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = merge(
    {
      "Name" = format("%s-default", var.name)
    },
    var.tags,
  )
}

########################
# Public route tables
########################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      "Name" = format("%s-public", var.name)
    },
    var.tags,
  )
}

resource "aws_route_table_association" "public" {
  count = length(var.az_subnets)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

########################
# Private route tables
########################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = merge(
    {
      "Name" = format("%s-private", var.name)
    },
    var.tags,
  )
}

resource "aws_route_table_association" "private" {
  count = length(var.az_subnets)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}