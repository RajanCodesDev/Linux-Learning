# Retrieve the security group by its Name tag

data "aws_security_group" "main" {
  filter {
    name   = "tag:Name"
    values = ["webserver_sg"]
  }
}