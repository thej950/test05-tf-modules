provider "aws" {
  region  = "us-east-1"
  profile = "thej"
}


# Networking Module
module "networking" {
  source            = "./modules/networking"
  vpc_name          = var.vpc_name
  cidr_block        = var.cidr_block
  public_subnet     = var.public_subnet
  private_subnet    = var.private_subnet
  availability_zone = var.availability_zone
}



# Security Group Module
module "security_group" {
  source        = "./modules/security-group"
  vpc_id        = module.networking.vpc_id
  ingress_ports = [22, 8080] # SSH and Jenkins
}

# EC2 Jenkins Module
module "ec2_jenkins" {
  source            = "./modules/ec2-jenkins"
  instance_type     = "t2.micro"
  ami_id            = "ami-0e2c8caa4b6378d8c" # ubuntu 
  subnet_id         = module.networking.public_subnet_id
  security_group_id = module.security_group.security_group_id
  key_name          = "abc" # this key need to available in local machine (download before this tf excute from aws console )
}
