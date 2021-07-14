resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.example.id
  cidr_block = var.vpc_cidr
  availability_zone = var.az
}

resource "aws_ec2_transit_gateway_vpc_attachment" "example" {
  subnet_ids         = [aws_subnet.my_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.example.id
  vpc_id             = aws_vpc.example.id
  depends_on = [ 
    aws_ec2_transit_gateway.example, 
  ]
}

resource "aws_internet_gateway" "vpc-igw" {
  vpc_id = "${aws_vpc.example.id}"
}

resource "aws_main_route_table_association" "main-vpc" {
  vpc_id         = "${aws_vpc.example.id}"
  route_table_id = "${aws_route_table.main-rt.id}"
}

resource "aws_route_table" "main-rt" {
  vpc_id = "${aws_vpc.example.id}"

  route {
    cidr_block = var.hvn_cidr
    transit_gateway_id = "${aws_ec2_transit_gateway.example.id}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc-igw.id}"
  }

  depends_on = [ 
      aws_ec2_transit_gateway.example,
      aws_ec2_transit_gateway_vpc_attachment.example,
  ]
}

resource "aws_security_group" "main-vpc-sg" {
  name        = "${var.Name}-main-vpc-sg"
  vpc_id      = "${aws_vpc.example.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8 # the ICMP type number for 'Echo'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0 # the ICMP type number for 'Echo Reply'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
  }
}

## Fetching AMI info
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "test-instance" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.my_subnet.id}"
  vpc_security_group_ids     = [ "${aws_security_group.main-vpc-sg.id}" ]
  key_name                    = "${aws_key_pair.test-tgw-keypair.key_name}"
  associate_public_ip_address = true
	user_data = <<EOT
		#!/bin/bash
    sudo apt-get update
		sudo apt-get install -y vim
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install vault
	EOT

}

resource "aws_key_pair" "test-tgw-keypair" {
  key_name   = "${var.Name}-keypair"
  public_key = "${var.public_key}"
}

output "PUBLIC_IP" { value = "${aws_instance.test-instance.public_ip}" }


