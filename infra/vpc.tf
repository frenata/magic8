provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "magic" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.magic.id
}

resource "aws_subnet" "magic_sub" {
  vpc_id                  = aws_vpc.ctf.id
  cidr_block              = "172.31.64.0/20"
  map_public_ip_on_launch = false
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.ctf.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "ra" {
  subnet_id      = aws_subnet.magic_sub.id
  route_table_id = aws_route_table.r.id
}
