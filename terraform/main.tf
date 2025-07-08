terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 5.0"
   }
 }

 backend "s3" {
   bucket = "quiz-app-akatsuki"
   key    = "terraform.tfstate"
   region = "us-east-1"
 }
}

# This is the AWS provider
provider "aws" {
 region = var.region
}

# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
 most_recent = true

 filter {
   name   = "name"
   values = [var.ami_name_filter]
 }

 filter {
   name   = "virtualization-type"
   values = ["hvm"]
 }

 owners = ["099720109477"]
}

resource "aws_vpc" "jumphost_vpc" {
 cidr_block           = var.vpc_cidr
 enable_dns_hostnames = true
 enable_dns_support   = true
}

resource "aws_subnet" "jumphost_subnet" {
 cidr_block = cidrsubnet(aws_vpc.jumphost_vpc.cidr_block, 4, 1)
 vpc_id     = aws_vpc.jumphost_vpc.id
}

resource "aws_internet_gateway" "jumphost_igw" {
 vpc_id = aws_vpc.jumphost_vpc.id

 tags = {
   Name = "main"
 }
}

resource "aws_route_table" "jumphost_route_table" {
 vpc_id = aws_vpc.jumphost_vpc.id

 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.jumphost_igw.id
 }
}

resource "aws_route_table_association" "jumphost_route_table_assoc" {
 subnet_id      = aws_subnet.jumphost_subnet.id
 route_table_id = aws_route_table.jumphost_route_table.id
}

# Security Group
resource "aws_security_group" "jumphost_SG" {
 name   = "jumphost_SG"
 vpc_id = aws_vpc.jumphost_vpc.id

 ingress {
   cidr_blocks = [var.allowed_ssh_cidr]
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
 }

 egress {
   from_port   = 0
   to_port     = 0
   protocol    = -1
   cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_key_pair" "jumphost_key" {
 key_name   = var.key_name
 public_key = var.public_key
}

resource "aws_iam_role" "jumphost_role" {
 name = "jumphost_role"

 assume_role_policy = jsonencode({
   Version = "2012-10-17"
   Statement = [
     {
       Action = "sts:AssumeRole"
       Effect = "Allow"
       Sid    = ""
       Principal = {
         Service = "ec2.amazonaws.com"
       }
     },
   ]
 })

 tags = {
   tag-key = "jumphost_tag_value"
 }
}

# This is an AWS IAM policy

resource "aws_iam_role_policy_attachment" "administrator_access_attach" {
 role       = aws_iam_role.jumphost_role.name
 policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "jumphost_instance_profile" {
 name = "jumphost_instance_profile"
 role = aws_iam_role.jumphost_role.name
}

# EC2 Instance
resource "aws_instance" "jumphost" {
 ami                         = data.aws_ami.ubuntu.id
 instance_type               = var.instance_type
 associate_public_ip_address = true
 key_name                    = aws_key_pair.jumphost_key.key_name
 vpc_security_group_ids      = [aws_security_group.jumphost_SG.id]
 subnet_id                   = aws_subnet.jumphost_subnet.id
 iam_instance_profile        = aws_iam_instance_profile.jumphost_instance_profile.name

 tags = {
   Name        = "Jumphost"
   Environment = var.environment
   Owner       = var.owner
 }

 user_data = file("../scripts/jumphost_init.sh")
}
