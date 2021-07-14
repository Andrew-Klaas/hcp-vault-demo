variable "region" {
  type = string
  default = "us-west-2"
}

variable "Name" {
  type = string
}

variable "owner" {
  type = string
}

variable "TTL" {
  type = number
}

variable "public_key" {
  type = string
}

variable "hvn_cidr" {
  type = string
  default = "172.25.16.0/20"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.1.0/24"
}

variable "az" {
  type = string 
  default = "us-west-2a"
}