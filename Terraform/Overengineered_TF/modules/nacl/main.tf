# webserversubnet_nacl

data "aws_network_acl" "main" {
  filter {
    name   = "tag:Name"
    values = ["webserver_subnet_nacl"]
  }
}