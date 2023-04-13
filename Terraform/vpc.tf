### VPC ###
resource "aws_vpc" "main" {
    cidr_block           = "10.132.0.0/16"
    instance_tenancy     = "default"
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "VPC Project"
    }
}

### PUBLIC SUBNETS ###
resource "aws_subnet" "public_subnet" {
    vpc_id                  = aws_vpc.main.id
    count                   = length(var.public_subnets_cidrs)
    cidr_block              = element(var.public_subnets_cidrs, count.index)
    availability_zone       = element(var.availability_zones, count.index)
    map_public_ip_on_launch = true

    tags = {
      Name = "Public-Subnet-${count.index + 1}"
    }
}

### PRIVATE SUBNETS ###
resource "aws_subnet" "private_subnet" {
    vpc_id                  = aws_vpc.main.id
    count                   = length(var.private_subnets_cidrs)
    cidr_block              = element(var.private_subnets_cidrs, count.index)
    availability_zone       = element(var.availability_zones, count.index)
    map_public_ip_on_launch = false

    tags = {
      Name = "Private-Subnet-${count.index + 1}"
    }
}

### SECURITY GROUP ###
resource "aws_security_group" "allow_http" {
    name        = "allow_http"
    description = "Allow HTTP inbound traffic"
    vpc_id      = aws_vpc.main.id   
    
    ingress {
      description      = "HTTP from VPC"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }   
    
    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }   
    
    tags = {
      Name = "allow_http"
    }
}

resource "aws_security_group" "allow_https" {
    name        = "allow_https"
    description = "Allow HTTPS inbound traffic"
    vpc_id      = aws_vpc.main.id   
    
    ingress {
      description      = "HTTPS from VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }   
    
    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }   
    
    tags = {
      Name = "allow_https"
    }
}

resource "aws_security_group" "allow_ssh" {
    name        = "allow_ssh"
    description = "Allow SSH inbound traffic"
    vpc_id      = aws_vpc.main.id   
    
    ingress {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }   
    
    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }   
    
    tags = {
      Name = "allow_ssh"
    }
}

### INTERNET GATEWAY ###
resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.main.id    
    
    tags = {
      Name = "Main Internet Gateway"
    }
}

### ELASTIC IP ###
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]
}

### NAT GATEWAY ###
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.internet_gateway]
  tags = {
    Name        = "NAT Gateway"
  }
}

### PUBLIC ROUTE TABLE ###
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id    
    
    tags = {
      Name = "Public Route Table"
    }
}

### PRIVATE ROUTE TABLE ###
resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main.id    
    
    tags = {
      Name = "Private Route Table"
    }
}

### PUBLIC ROUTE ###
resource "aws_route" "public_route" {
    route_table_id         = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.internet_gateway.id
    depends_on             = [aws_route_table.public_rt]
}

### PRIVATE ROUTE ###
resource "aws_route" "private_route" {
    route_table_id         = aws_route_table.private_rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat_gateway.id
    depends_on             = [aws_route_table.private_rt]
}

### PUBLIC ROUTE TABLE ASSOCIATION ###
resource "aws_route_table_association" "public_rt_association" {
    count = length(var.public_subnets_cidrs)
    subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
    route_table_id = aws_route_table.public_rt.id
}

### PRIVATE ROUTE TABLE ASSOCIATION ###
resource "aws_route_table_association" "private_rt_association" {
    count = length(var.private_subnets_cidrs)
    subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
    route_table_id = aws_route_table.private_rt.id
}