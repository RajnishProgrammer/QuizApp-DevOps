variable "region" {
 default = "us-east-1"
}

variable "vpc_cidr" {
 default = "10.0.0.0/16"
}

variable "instance_type" {
 default = "t2.micro"
}

variable "ami_name_filter" {
 default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "allowed_ssh_cidr" {
 default = "0.0.0.0/0"
}

variable "key_name" {
 default = "my-custom-key-v2"
}

variable "public_key" {
 description = "Your SSH public key"
 default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMmWx5SdTEnn5OZwhY8DcsFdEifuQDVbtULtWQupF0mpJY9WwccHNAp2anF3k7WEB35O5HMlQ3vFyvJSIpKy6yHj2whXqMESWK6MPtBwICKIATXl1NvE+SpqQFBzKV4yPEZqnvPNVIYVkB29z0MPK16e3+OQqIKO9Qp2pAl0IGsmopD2nhcKa6f8SwlOwHX3SIwvqZuirckBCZSDes5rLKxoC+uFbBEealbtnJQeHZLYClYBsMMHmFUHSAG2WHmtMaeKJ2G+CUqNQhH+hfXb4SVLjxjZ4cFjirQrWMe+5ViwWz+gjd9XpNbGCeC/jHK8XPEdVKjUjViwebBrKFVDSh" # Add your public key here
}

variable "environment" {
 default = "DevOpsProject"
}

variable "owner" {
 default = "Akatsuki"
}