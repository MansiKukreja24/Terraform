provider "aws" {
    region = "ap-south-1"
    shared_credentials_file = "/Users/mansi/.aws/credentials"
    profile = "default"
}

resource "tls_private_key" "web1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web1" {
  key_name   = "terra"
  public_key = tls_private_key.web1.public_key_openssh
}

resource "aws_security_group" "web1" {
  name        = "web1-security-group"
  description = "Allow HTTP, HTTPS and SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform"
  }
}


resource "aws_instance" "web1" { 
  key_name      = aws_key_pair.web1.key_name
  ami           = "ami-0ad704c126371a549"
  instance_type = "t2.micro"
  
  tags = {
    Name = "terra"
  }

}
resource "aws_ebs_volume" "web1" {
  availability_zone = aws_instance.web1.availability_zone
  size              = 1

  tags = {
    Name = "Web Server HD"
  }
}

resource "aws_volume_attachment" "web1" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.web1.id
  instance_id = aws_instance.web1.id
}

