variable "region" {
  type    = string
  default = "us-east-1"
}
variable "project" {
  type    = string
  default = "pbl-vle4"
}
variable "instance_type" {
  type    = string
  default = "t3.micro" # free-tier eligible
}
variable "ssh_cidr" {
  description = "Your IP in CIDR form, e.g. 49.36.10.5/32 (curl ifconfig.me)"
  type        = string
  default     = "0.0.0.0/0"
}
