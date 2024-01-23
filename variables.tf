variable "aws_region" {
  description = "The AWS region"
  default     = "us-east-1" # add region of your choice
}

variable "ami_id" {
  default = "ami-0df435f331839b2d6" # latest ami # add your region's ami id if want to test for specific ami
}
variable "instance_type" {
  default = "t2.micro" # can be changed as per requirement
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16" #to be changed if range is not available in your account
}

variable "public_subnet_cidr_block_A" {
  default     = "10.0.0.0/24"  #to be changed if range is not available in your account
}

variable "private_subnet_cidr_block_A" {
  default     = "10.0.16.0/20" #to be changed if range is not available in your account
}

variable "public_subnet_cidr_block_B" {
  default     = "10.0.1.0/24"  #to be changed if range is not available in your account
}

variable "private_subnet_cidr_block_B" {
  default     = "10.0.32.0/20" #to be changed if range is not available in your account
}

variable "availability_zones_A" {
  default     = "us-east-1a"
}

variable "availability_zones_B" {
  default     = "us-east-1b"
}