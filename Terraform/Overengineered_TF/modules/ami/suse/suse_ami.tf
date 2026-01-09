data "aws_ami" "suse" {
  most_recent = true
  owners      = ["011122641926"]  # SUSE

  filter {
    name   = "name"
    values = ["suse-sles-15-sp2-*"]
  }
}
