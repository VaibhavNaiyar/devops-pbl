# Practice 8 - S3 bucket with Terraform (versioning, encryption, public access block, lifecycle)
terraform {
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "aws" { region = var.region }

variable "region" {
  type    = string
  default = "us-east-1"
}

resource "random_id" "suffix" { byte_length = 4 }

resource "aws_s3_bucket" "lab" {
  bucket        = "pbl2-s3-lab-${random_id.suffix.hex}"
  force_destroy = true # lets `terraform destroy` remove non-empty bucket
  tags          = { Name = "pbl2-s3-lab", ManagedBy = "Terraform" }
}

resource "aws_s3_bucket_versioning" "lab" {
  bucket = aws_s3_bucket.lab.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lab" {
  bucket = aws_s3_bucket.lab.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "lab" {
  bucket                  = aws_s3_bucket.lab.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "lab" {
  bucket = aws_s3_bucket.lab.id
  rule {
    id     = "expire-old-versions"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration { noncurrent_days = 30 }
  }
}

output "bucket_name" { value = aws_s3_bucket.lab.bucket }
output "bucket_arn"  { value = aws_s3_bucket.lab.arn }
