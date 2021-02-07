provider "aws"{
    region = "us-east-1"
}

/*
  variables to set vpc networking
*/

variable "vpc_cidr"{
  description= "vpc cidr range"
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
/*
  vpc module that creates
  vpc with given name as 
  argument in tag
*/
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

/*
  module that creates two
  internet gateway with
  given name in tag
*/
module "internet_gateway"{
  source = "./modules/internet_gateway"
  vpc_id = module.vpc.vpc.id
  name = "tf_practice_ig"
}

/*
  module that subnet
  with given subnet cidr,
  attach it to given vpc
  and given name in tag
*/
module "lb_public_subnet_1" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc.id
  name = "tf_public_subnet"
  subnet_cidr = var.lb_public_subnet_1_cidr
  availability_zone = "us-east-1a"
}

module "nginx_private_subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc.id
  name = "nginx_private_subnet"
  subnet_cidr = var.nginx_private_subnet_cidr
  availability_zone = "us-east-1a"
}

module "lb_private_subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc.id
  name = "lb_private_subnet"
  subnet_cidr = var.lb_private_subnet_cidr
  availability_zone = "us-east-1a"
}

module "app_server_private_subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc.id
  name = "app_server_private_subnet"
  subnet_cidr = var.app_server_private_subnet_cidr
  availability_zone = "us-east-1a"
}

module "lb_public_subnet_2" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc.id
  name = "lb_public_subnet_2"
  subnet_cidr = var.lb_public_subnet_2_cidr
  availability_zone = "us-east-1b"
}

module "nginx_private_subnet_2" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc.id
  name = "nginx_private_subnet_2"
  subnet_cidr = var.nginx_private_subnet_2_cidr
  availability_zone = "us-east-1b"
}

module "lb_private_subnet_2" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc.id
  name = "lb_private_subnet_2"
  subnet_cidr = var.lb_private_subnet_2_cidr
  availability_zone = "us-east-1b"
}

module "app_server_private_subnet_2" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc.id
  name = "app_server_private_subnet_2"
  subnet_cidr = var.app_server_private_subnet_2_cidr
  availability_zone = "us-east-1b"
}
/*
  module that route table
  with given list of routes,
  attach it to given vpc
  and given name in tag
*/
module "public_route_table"{
  source = "./modules/route_table"
  vpc_id = module.vpc.vpc.id
  name = "tf_practice_public_rt"
  route = [
    {
      "cidr_block" : var.default_cidr,
      "egress_only_gateway_id" : null,
      "gateway_id" : module.internet_gateway.ig.id,
      "instance_id" : null,
      "ipv6_cidr_block" : null,
      "local_gateway_id" : null,
      "nat_gateway_id" : null,
      "network_interface_id" : null,
      "transit_gateway_id" : null,
      "vpc_endpoint_id" : null,
      "vpc_peering_connection_id" : null
    }
  ]
}

module "public_route_table_2" {
  source = "./modules/route_table"
  vpc_id = module.vpc.vpc.id
  name = "lb_public_rt_2"
  route  = [
    {
      "cidr_block" : var.default_cidr,
      "egress_only_gateway_id" : null,
      "gateway_id" : module.internet_gateway.ig.id,
      "instance_id" : null,
      "ipv6_cidr_block" : null,
      "local_gateway_id" : null,
      "nat_gateway_id" : null,
      "network_interface_id" : null,
      "transit_gateway_id" : null,
      "vpc_endpoint_id" : null,
      "vpc_peering_connection_id" : null
    }
  ]
}

/*
  creating route table
  association with subnet
*/
resource "aws_route_table_association" "tf_practice_rt_subnet_as" {
    subnet_id = module.lb_public_subnet_1.subnet.id
    route_table_id = module.public_route_table.rt.id
  
}

resource "aws_route_table_association" "lb_public_rt_subnet_as"{
  subnet_id =  module.lb_public_subnet_2.subnet.id
  route_table_id =  module.public_route_table_2.rt.id
}

/*
  module that  creates security
  groups with given list of
  ingress routes and egress routes,
  attach it to given vpc
  and given name in tag
*/

module "lb_public_sg_1"{
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc.id
  ingress_routes = [
    {
      "cidr_blocks" : [var.default_cidr ],
      "description" : "allow http from world",
      "from_port" : 80,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "tcp",
      "security_groups" : null,
      "self" : null,
      "to_port" : 80
    }
  ]
  egress_routes = [
    {
      "cidr_blocks" : [ var.default_cidr ],
      "description" : "Allow all",
      "from_port" : 0,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "-1",
      "security_groups" : null,
      "self" : null,
      "to_port" : 0
    }
  ]
  name = "lb_public_sg_1"
}

module "webserver_private_sg_1"{
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc.id
  ingress_routes = [
    {
      "cidr_blocks" : ["10.0.0.0/16"],
      "description" : "allow http from world",
      "from_port" : 80,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "tcp",
      "security_groups" : null,
      "self" : null,
      "to_port" : 80
    }
  ]
  egress_routes = [
    {
      "cidr_blocks" : [ var.default_cidr ],
      "description" : "Allow all",
      "from_port" : 0,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "-1",
      "security_groups" : null,
      "self" : null,
      "to_port" : 0
    }
  ]
  name = "webserver_private_sg_1"
}

module "webserver_private_sg_2"{
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc.id
  ingress_routes = [
    {
      "cidr_blocks" : [var.lb_public_subnet_2_cidr],
      "description" : "allow http from world",
      "from_port" : 80,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "tcp",
      "security_groups" : null,
      "self" : null,
      "to_port" : 80
    }
  ]
  egress_routes = [
    {
      "cidr_blocks" : [ var.default_cidr ],
      "description" : "Allow all",
      "from_port" : 0,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "-1",
      "security_groups" : null,
      "self" : null,
      "to_port" : 0
    }
  ]
  name = "webserver_private_sg_2"
}
module "public_lb_tg" {
  source = "./modules/target_groups"
  name = "public-lb-1-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = module.vpc.vpc.id
}

module "public_lb_1" {
  source = "./modules/load_balancer"
  name = "public-lb-1"
  internal =  false
  load_balancer_type = "application"
  security_groups = [module.lb_public_sg_1.sg.id]
  subnet_id = [module.lb_public_subnet_1.subnet.id, module.lb_public_subnet_2.subnet.id]

  enable_deletion_protection = false

  Environment = "dev"
}

resource "aws_lb_listener" "lb_endpoint_1" {
  load_balancer_arn = module.public_lb_1.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.public_lb_tg.tg.arn
  }
}

data  "aws_ami" "packer_AMI" {
  most_recent = true

  filter {
    name = "name"
    values =  ["packerAMI"]
  }

  owners = ["208269834922"]
}

module "nginx_public_launch_template" {
  source = "./modules/launch_template"
  name = "nginx_public_launch_template"
  ami =  data.aws_ami.packer_AMI.id
  instance_type = "t2.micro"
  shutdown_behavior = "terminate"
  key_name = "tf-practice-aws"
  security_groups_id = [module.webserver_private_sg_1.sg.id]
}

module "nginx-private_asg-1"{
  source = "./modules/auto_scaling_group"
  name = "nginx-private_asg-1"
  max_size = 2
  min_size = 2
  health_check_type = "ELB"
  desired_capacity = 2
  force_delete = true
  availability_zones = [module.nginx_private_subnet.subnet.id, module.nginx_private_subnet_2.subnet.id]
  // load_balancers = [module.public_lb_1.lb.name]
  target_group_arns = [module.public_lb_tg.tg.arn]
  launch_template_id = module.nginx_public_launch_template.lt.id
}

