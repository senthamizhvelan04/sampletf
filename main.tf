resource "aws_vpc" "tfvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "tfvpc"
  }
}

resource "aws_subnet" "tfsubnet" {
  vpc_id     = aws_vpc.tfvpc.id
  cidr_block = "10.0.1.0/24"


}

resource "aws_internet_gateway" "tfinternetgateway" {
  vpc_id = aws_vpc.tfvpc.id
}

resource "aws_route_table" "tfroute" {
  vpc_id = aws_vpc.tfvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tfinternetgateway.id
  }
}

resource "aws_route_table_association" "tfrouteassoc" {
  subnet_id      = aws_subnet.tfsubnet.id
  route_table_id = aws_route_table.tfroute.id
}

resource "aws_security_group" "tfsecgroup" {
  name        = "tfsecgroup"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.tfvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tfsecgroup"
  }
}

resource "aws_instance" "example" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.tfsubnet.id
  vpc_security_group_ids      = [aws_security_group.tfsecgroup.id]
  associate_public_ip_address = true

  tags = {
    Name = "tfinstance"
  }
}