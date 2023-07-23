variable "subnet_id" {
    type = string
    description = "subnet id"
}

variable "instance_type" {
    type = string
    description = "instance type"
}

variable "key_name" {
    type = string
    description = "ssh keypair specified for the instance"
}

variable "ami_id" {
    type = string
    default = "ami-020737107b4baaa50" 
    description = "ami to be used"
}

variable "region" {
    type = string
    default = "eu-west-2"
    description = "region within AWS"
  
}