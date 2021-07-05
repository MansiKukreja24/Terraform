provider "aws" {
    region = "us-east-1"
    shared_credentials_file = "C:/Users/mansi/.aws/credentials"
    profile = "default"
}

resource "aws_vpc" "task5" {
  cidr_block       = var.cidr_block
  tags = {
    Name = "lwterra"
  }
  enable_dns_support   = true
  enable_dns_hostnames = true

}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.task5.id
  cidr_block        = var.subnet
  tags = {
    Name = "task5_subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.task5.id
  tags = {
    Name = "task5_gw"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.task5.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.task5.cidr_block]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.task5.cidr_block]
  }
   ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.task5.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.task5.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "default route table"
  }
}

resource "aws_instance" "task5" {
  ami                    = "ami-0ab4d1e9cf9a1215a" #id of desired AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  key_name = var.keyname

  user_data              = <<-EOF
    #!/bin/bash
    yum update -y        
    yum install -y httpd 
    service httpd start  
    chkconfig httpd on   
    echo "<p><h2>My key skills are: </h2><br> AWS<br>Terraform<br>Linux<br>Django<br>Python<br>Java<br>Wordpress" > /var/www/html/index.html
    EOF

  tags = {
      Name = "Web_Server_VPC"
  }

  }
  resource "aws_eip" "lb" {
  instance = aws_instance.task5.id
  vpc      = true
  depends_on                = [aws_internet_gateway.gw]
}


resource "aws_ebs_volume" "example" {
  availability_zone = aws_instance.task5.availability_zone
  size = 40

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_ebs_snapshot" "example_snapshot" {
  volume_id = aws_ebs_volume.example.id

  tags = {
    Name = "HelloWorld_snap"
  }
}



