
variable "instance_type" {
    type = string
    description = "EC2 instance type"
}

variable "region" {
    type = string
    description = "AWS Region"
}

variable "ami_id" {
  type = string
  description = "Ubuntu AMI ID"
}

variable "vpc_cidr_block" {
  type = string
  description = "CIDR block for a particular VPC"
}

variable "key_name" {
  type = string
  description = "Key Pair attached to EC2 for login access."
}