provider "aws" {
  region = "ap-south-1"
  shared_credentials_file = "C:/Users/mansi/.aws/credentials"
  profile = "default"
}

resource "aws_instance" "ec2" {
  ami = "ami-011c99152163a87ae"
  instance_type = "t2.micro"
  depends_on = [
    aws_db_instance.mysql,
  ]

  key_name = "devops"
  security_groups = ["web1-security-group"]
  
  resource "null_resource". "test1" {
 connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/mansi/Downloads/devops.pem"​)
    host     = aws_instance.ec2.public_ip
  }


 provisioner "remote-exec"​ {
    inline = [
      "sudo yum install http -y",
      "sudo yum install php -y",
      "sudo systemctl start httpd",
      "sudo systemctl start php",
      "cd /var/www/html",
      "sudo wget https://wordpress.org/latest.zip",
      "sudo unzip latest.zip"
    ]
  }
}
  resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = var.dbname
  username               = var.username
  password               = var.password
  parameter_group_name   = "default.mysql5.7"
  security_groups = ["web1-security-group"]
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  skip_final_snapshot    = true
}
