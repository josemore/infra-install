variable "profile" {
  default = "default"
}

variable "region" {
  default = "eu-west-1"
}

variable "instance" {
  default = "t2.nano"
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
  default     = ["ubuntu18", "ubuntu16", "ubuntu14", "ubuntu12"]
}

variable "amis" {
  description = "AMIs for the distributions to test install"
  type        = list(string)
  default     = ["ami-0c32816f296ee28e5", "ami-04bfff099c4b1d8ed", "ami-0a273e2936ffb0ab9", "ami-ee0b0688"]
}

variable "ami_users" {
  description = "Users for the distributions to test install"
  type        = list(string)
  default     = ["ubuntu", "ubuntu", "ubuntu", "ubuntu"]
}
