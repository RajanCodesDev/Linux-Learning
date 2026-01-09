output "key_name" {
  description = "Key Name"
  value       = data.aws_key_pair.main.key_name
}