variable "aws_region" {
  default = "ap-southeast-1"
}

variable "az" {
  default = "ap-southeast-1a"
}

variable "ami_id" {
  description = "Ubuntu AMI"
}

variable "key_name" {
  description = "SSH key name"
}
