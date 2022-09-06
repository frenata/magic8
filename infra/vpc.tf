provider "aws" {
  region = "us-west-1"
}

resource "aws_vpc" "magic" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.magic.id
}

resource "aws_subnet" "one" {
  vpc_id                  = aws_vpc.magic.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-1b"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "two" {
  vpc_id                  = aws_vpc.magic.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-1c"
  map_public_ip_on_launch = false
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.magic.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "ra_one" {
  subnet_id      = aws_subnet.one.id
  route_table_id = aws_route_table.r.id
}

resource "aws_route_table_association" "ra_two" {
  subnet_id      = aws_subnet.two.id
  route_table_id = aws_route_table.r.id
}
