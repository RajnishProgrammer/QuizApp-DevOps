output "jumphost_public_ip" {
 description = "The public IP of the jumphost"
 value       = aws_instance.jumphost.public_ip
}

output "jumphost_ssm_instance_id" {
 description = "Instance ID for use with AWS SSM"
 value       = aws_instance.jumphost.id
}