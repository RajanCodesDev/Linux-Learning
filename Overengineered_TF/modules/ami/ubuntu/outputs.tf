output "id" {
  description = "The latest Ubuntu AMI ID"
  value       = data.aws_ami.ubuntu.id
}
