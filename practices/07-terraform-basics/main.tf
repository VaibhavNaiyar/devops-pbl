# Practice 7 - Terraform basics: providers, variables, resources, outputs, state
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "pbl2-terraform-basics"
}

resource "random_pet" "suffix" {
  length = 2
}

# Look up the default VPC (data source example)
data "aws_vpc" "default" {
  default = true
}

# A security group - free resource, good to demo plan/apply/destroy
resource "aws_security_group" "demo" {
  name        = "${var.project}-${random_pet.suffix.id}"
  description = "Terraform basics demo SG"
  vpc_id      = data.aws_vpc.default.id

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

  tags = { Name = var.project, ManagedBy = "Terraform" }
}

output "security_group_id" { value = aws_security_group.demo.id }
output "default_vpc_id"    { value = data.aws_vpc.default.id }
