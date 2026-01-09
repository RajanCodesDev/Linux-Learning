data "aws_internet_gateway" "main" {
  filter {
    name   = "tag:Name"
    values = ["webserver_igw"]  # Replace with your IGW name
  }
}