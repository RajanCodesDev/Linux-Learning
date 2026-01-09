data "aws_key_pair" "main" {
  filter {
    name   = "tag:Name"
    values = ["6Jan26aws"]
  }
}
