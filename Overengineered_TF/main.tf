provider "aws" {
  region = "ap-south-1"
}

module "ami" {
  source = "./modules/ami/ubuntu"
}

module "vpc" {
  source = "./modules/vpc"
}
module "subnet" {
  source = "./modules/subnet"
}
# NACL module is commented out ( does not exist in hashicorp as a data block )
# module "nacl" {
#   source = "./modules/nacl"
# }

module "security_group" {
  source = "./modules/security_group"
}
# key_name not able to fetch from module
# module "key_pair" {
#   source = "./modules/keys"
# }



resource "aws_instance" "web" {
  ami                    = module.ami.id
  instance_type          = "t2.nano"
  subnet_id              = module.subnet.id
  vpc_security_group_ids = [module.security_group.id]
  key_name               = "6Jan26aws"

  associate_public_ip_address = true


  tags = {
    Name = "UbuntuWebServer"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
