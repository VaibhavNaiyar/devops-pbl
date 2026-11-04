variable "region" {
  type    = string
  default = "us-east-1"
}
variable "project" {
  type    = string
  default = "shop"
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "app_image" {
  description = "Docker image to run. Push vle/05 app to Docker Hub and set e.g. yourname/pbl-shop:1.0.0"
  type        = string
  default     = "yourdockerhubuser/pbl-shop:1.0.0"
}
variable "app_version" {
  type    = string
  default = "1.0.0"
}
variable "app_port" {
  type    = number
  default = 3000
}
variable "health_path" {
  type    = string
  default = "/health"
}
