/*
//   variables to set vpc networking
// */

variable "vpc_cidr" {
  description = "vpc cidr range"
}


variable "tf_instance_ip_address" {
  description = "ip address for public tf_practice instance"
}

variable "default_cidr" {
  description = "default route"
}

variable "lb_public_subnet_1_cidr" {
  description = "public load balancer subnet"
}

variable "nginx_private_subnet_cidr" {}

variable "lb_private_subnet_cidr" {}

variable "app_server_private_subnet_cidr" {}

variable "lb_public_subnet_2_cidr" {}

variable "nginx_private_subnet_2_cidr" {}

variable "lb_private_subnet_2_cidr" {}

variable "app_server_private_subnet_2_cidr" {}

variable "vpc2_instance_private_ip" {}

variable "vpc_cidr_2" {}

variable "vpc2_public_subnet" {}