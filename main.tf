## PROVIDER #####################################################

# Set a provider
provider "aws"{
  region = "eu-west-1"
}

## RESOURCES ####################################################

# Create a VPC
resource "aws_vpc" "two_tier_vpc"{
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.instance_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "two_tier_gw" {
  vpc_id = aws_vpc.two_tier_vpc.id
  tags = {
    Name = var.instance_name
  }
}

# Create a subnets
resource "aws_subnet" "two_tier_subnet_pub"{
  vpc_id            = aws_vpc.two_tier_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "${var.instance_name}-public"
  }
}
resource "aws_subnet" "two_tier_subnet_pri"{
  vpc_id            = aws_vpc.two_tier_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "${var.instance_name}-pri"
  }
}

# Route Table
resource "aws_route_table" "app_route_table_pub"{
  vpc_id = aws_vpc.two_tier_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.two_tier_gw.id
  }
  tags = {
    Name = "${var.instance_name}-pub"
  }
}
resource "aws_route_table" "app_route_table_pri"{
  vpc_id = aws_vpc.two_tier_vpc.id
  route {
    }
  tags = {
    Name = "${var.instance_name}-pri"
  }
}

# Route Table Associations
resource "aws_route_table_association" "pub_assoc"{
  subnet_id = aws_subnet.two_tier_subnet_pub.id
  route_table_id = aws_route_table.app_route_table_pub.id
}
resource "aws_route_table_association" "pri_assoc"{
  subnet_id = aws_subnet.two_tier_subnet_pri.id
  route_table_id = aws_route_table.app_route_table_pri.id
}

# Create security group
resource "aws_security_group" "pub_sg" {
  vpc_id        = aws_vpc.two_tier_vpc.id
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["212.161.55.68/32"]
  }
  tags = {
    Name = "${var.instance_name}-public"
  }
}
resource "aws_security_group" "pri_sg" {
  vpc_id        = aws_vpc.two_tier_vpc.id
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["212.161.55.68/32"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  tags = {
    Name = "${var.instance_name}-private"
  }
}
