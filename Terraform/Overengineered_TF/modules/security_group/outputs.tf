# Output ID

output "id" {
  description = "Security Group ID"
  value = data.aws_security_group.main.id   
}