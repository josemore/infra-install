variable "profile" {
  default = "default"
}

variable "region" {
  default = "eu-west-1"
}

variable "instance" {
  default = "t2.micro"
}

variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "private_key" {
  default = "~/.ssh/id_rsa"
}

variable "environment_tag" {
  default = "us-development"
}

variable "owning_team_tag" {
  default = "IHOST"
}

variable "product_tag" {
  default = "infrastructure"
}

variable "distros" {
  description = "Distributions to test install (co-indexed with amis and ami_users)"
  type        = list(string)
  default     = ["ubuntu20", "ubuntu18", "ubuntu16", "ubuntu14", "ubuntu12", "amazon2", "amazon", "centos8", "centos7", "centos6", "debian10", "debian9", "debian8", "rhel8", "rhel7", "rhel6", "sles152", "sles125", "sles114"]
}

variable "amis" {
  description = "AMIs for the distributions to test install"
  type        = list(string)
  default     = ["ami-0383535ce92966dfe", "ami-0c32816f296ee28e5", "ami-04bfff099c4b1d8ed", "ami-0a273e2936ffb0ab9", "ami-ee0b0688", "ami-08a2aed6e0a6f9c7d", "ami-0a7c31280fbd23a86", "ami-0bfa4fefe067b7946", "ami-0d4002a13019b7703", "ami-000e5005b9dd14cf8", "ami-093185e1a0acee74b", "ami-0442db6463774080a", "ami-402f1a33", "ami-08f4717d06813bf00", "ami-012d8ddfa1b0b8c46", "ami-04d055a70d2d190b9", "ami-051cbea0e7660063d", "ami-0d34987ebe4d9338c", "ami-0a40ff0e3202c10e1"]
}

variable "ami_users" {
  description = "Users for the distributions to test install"
  type        = list(string)
  default     = ["ubuntu", "ubuntu", "ubuntu", "ubuntu", "ubuntu", "ec2-user", "ec2-user", "centos", "centos", "root", "admin", "admin", "admin", "ec2-user", "ec2-user", "ec2-user", "ec2-user", "ec2-user", "ec2-user"]
}
