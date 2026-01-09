data "aws_ami" "windows" {
  most_recent = true
  owners      = ["801119661308"]  # Microsoft

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}
