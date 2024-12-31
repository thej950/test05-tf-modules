# This file is a Global variables defining 
variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "The name of the SSH key pair"
  default     = "my-key"
}

variable "vpc_name" {
  type        = string
  description = "My vpc name"
}
variable "cidr_block" {
  type        = string
  description = "main-vpc cidr"
}

variable "availability_zone" {
  type        = list(string)
  description = "availabilty zones"
}

variable "public_subnet" {
  type        = string
  description = "CIDR block for the public subnet public subnet cidr inside main-vpc"
}

variable "private_subnet" {
  type        = string
  description = "CIDR block for the private subnet private subnet cidr inside main-vpc"
}
