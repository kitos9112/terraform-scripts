variable "vpc_region" {}
variable "tfstate_bucket" {}
variable "rds_username" {}
variable "rds_password" {}
variable "rds_size" {}

provider "aws" {
    region = "${var.vpc_region}"
}

data "terraform_remote_state" "vpc" {
	backend = "s3"
	config {
		region = "${var.vpc_region}"
		bucket = "${var.tfstate_bucket}"
		key = "aws_training/vpc/terraform.tfstate"
	}
}

resource "aws_db_subnet_group" "rds_subnets" {
    name = "main"
    subnet_ids = ["${split(",",data.terraform_remote_state.vpc.public_subnets)}"]
    tags {
        Name = "RDS Subnets"
    }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.6"
  instance_class       = "${var.rds_size}"
  name                 = "mydb"
  username             = "${var.rds_username}"
  password             = "${var.rds_password}"
  db_subnet_group_name = "${aws_db_subnet_group.rds_subnets.name}"
  parameter_group_name = "default.mysql5.6"
}