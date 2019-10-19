# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}
 
# Create a VPC
resource "aws_vpc" "amaechidevops" {
  cidr_block = "10.0.0.0/16"
 
 tags = {
    Name = "amaechidevops"
 }
}

resource "aws_subnet" "amasubnet1" {
  vpc_id     = "${aws_vpc.amaechidevops.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "amasubnet1"
  }
}
 resource "aws_subnet" "amasubnet2" {
  vpc_id     = "${aws_vpc.amaechidevops.id}"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "amasubnet2"
  }
} 

resource "aws_internet_gateway" "ama-route-gw" {
  vpc_id = "${aws_vpc.amaechidevops.id}"

  tags = {
    Name = "amadevops-gw"
  }
}

 resource "aws_route_table" "amaechidevops-route-table" {
  vpc_id = "${aws_vpc.amaechidevops.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ama-route-gw.id}"
  }
   tags = {
    Name = "ama-route-table"
  }
}
#route-table association1
resource "aws_route_table_association" "amaechidevops-route-associate1" {
  subnet_id      = "${aws_subnet.amasubnet1.id}"
  route_table_id = "${aws_route_table.amaechidevops-route-table.id}"
}

#route-table association2
 resource "aws_route_table_association" "amaechidevops-route-associate2" {
  subnet_id      = "${aws_subnet.amasubnet2.id}"
  route_table_id = "${aws_route_table.amaechidevops-route-table.id}"
}

# Define the security group for public subnet
resource "aws_security_group" "amaechidevops-SG" {
  vpc_id = "${aws_vpc.amaechidevops.id}"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "amaechidevops-SG"
  }
}
resource "aws_instance" "amaechi-ec2" {
  ami = "ami-0c322300a1dd5dc79"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.amasubnet1.id}"  
  key_name = "amaec1"
  security_groups = ["${aws_security_group.amaechidevops-SG.id}"]
  user_data = << EOF
		#! /bin/bash
                sudo yum install httpd -y
		sudo echo 
		sudo systemctl start httpd
		sudo systemctl enable httpd
		echo "Automation for the people" /var/www/html/index.html
	EOF

tags = {
    Name = "amaechi-ec2"
  }
}

resource "aws_eip" "amaechi-ec2-ip" {
  instance = "${aws_instance.amaechi-ec2.id}"
  vpc      = true
}
