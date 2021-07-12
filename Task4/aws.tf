provider "aws" {
  region = "ap-south-1"
  shared_credentials_file = "C:/Users/mansi/.aws/credentials"
  profile = "default"
}

resource "aws_security_group" "rds" {
  name        = "terraform_rds_security_group"
  description = "Terraform example RDS MySQL server"    
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]    
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-example-rds-security-group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = var.name
  username             = var.username
  password             = var.password
  parameter_group_name = "default.mysql5.7" 
  skip_final_snapshot  = true
  backup_retention_period = 0
  apply_immediately    = true
  publicly_accessible  = true  
  vpc_security_group_ids    = [aws_security_group.rds.id]
}

