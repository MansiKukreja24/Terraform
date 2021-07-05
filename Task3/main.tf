provider "aws" {

  region  = "ap-south-1"
  shared_credentials_file = "/Users/mansi/.aws/credentials"
  profile = "default"
  
}

resource "aws_instance" "wordpress" {
  ami           = "ami-011c99152163a87ae"
  instance_type = "t2.micro"
  security_groups = ["web1-security-group"]
  
  key_name = "devops"
  tags = { 
    Name = "wordpress"
  }
}



resource "aws_db_instance" "default" {
  identifier           = "wordpress1"
  allocated_storage    = 20
  
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "wordpress"
  username             = "root"
  password             = "hey123!!"
  publicly_accessible  = true
  skip_final_snapshot  = true
} 
resource "null_resource" "re2" {
  
  
  
connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/mansi/Downloads/devops.pem")
    host = aws_instance.wordpress.public_ip
  }

provisioner "remote-exec" {
     inline = [
      "sudo yum -y install httpd",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]
  }
}

