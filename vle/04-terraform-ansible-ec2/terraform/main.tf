# VLE 4 - Provision EC2 with Terraform, then configure with Ansible
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws   = { source = "hashicorp/aws", version = "~> 5.0" }
    tls   = { source = "hashicorp/tls", version = "~> 4.0" }
    local = { source = "hashicorp/local", version = "~> 2.5" }
  }
}

provider "aws" { region = var.region }

data "aws_vpc" "default" { default = true }

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# Generate an SSH key pair and save the private key locally
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.project}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_sensitive_file" "pem" {
  filename        = "${path.module}/../${var.project}-key.pem"
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0400"
}

resource "aws_security_group" "web" {
  name        = "${var.project}-sg"
  description = "SSH + HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options { http_tokens = "required" } # IMDSv2

  tags = { Name = "${var.project}-web", ManagedBy = "Terraform", ConfiguredBy = "Ansible" }
}

# Auto-generate Ansible inventory from Terraform output
resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-INV
    [web]
    ${aws_instance.web.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${abspath(local_sensitive_file.pem.filename)}
  INV
}
