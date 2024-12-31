# Variables
variable "vpc_name" {}
variable "cidr_block" {}
variable "public_subnet" {}
variable "private_subnet" {}
variable "availability_zone" {}

# VPC Resource
resource "aws_vpc" "main-vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.vpc_name
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = var.public_subnet
  availability_zone       = var.availability_zone[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${var.vpc_name}"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = var.private_subnet
  availability_zone       = var.availability_zone[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-${var.vpc_name}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "igw-${var.vpc_name}"
  }
}

/*
# NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "nat-eip-${var.vpc_name}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "nat-gw-${var.vpc_name}"
  }
}
*/
# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-RT-${var.vpc_name}"
  }
}

# Associate Public Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


/*
#----------------------------------------------------
# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-RT-${var.vpc_name}"
  }
}

# Associate Private Route Table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
#-----------------------------------------------------
*/

# Outputs
output "vpc_id" {
  value = aws_vpc.main-vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

/*
output "private_subnet_id" {
  value = aws_subnet.private.id
}
*/

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

/*
output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gw.id
}
*/