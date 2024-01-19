variable "aws_region" {
  description = "The AWS region"
  default     = "us-east-1" # add region of your choice
}

variable "ami_id" {
  default = "ami-0df435f331839b2d6" # add your region's ami id if want to test for specific ami
}
variable "instance_type" {
  default = "t2.micro" # can be changed as per requirement
}
variable "instance_key_name" {
  description = "The name of the SSH key to associate to the instance. Note that the key must exist already."
  default     = "Mrini-Nov 2023" #add your key name here
}