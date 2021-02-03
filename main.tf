provider "aws"{
    region = "us-east-1"
}
/*
  variables to set vpc networking
*/

variable "vpc_cidr"{
  description= "vpc cidr range"
}
variable "public_subnet_1_cidr" {
  description = "cidr block for tf_practice_subnet_1"
}

variable "tf_instance_ip_address" {
  description = "ip address for public tf_practice instance"
}

variable "default_cidr" {
  description = "default route"
}
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

module "public_subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc.id
  name = "tf_public_subnet"
  subnet_cidr = var.public_subnet_1_cidr
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

/*
  creating route table
  association with subnet
*/
resource "aws_route_table_association" "tf_practice_rt_subnet_as" {
    subnet_id = module.public_subnet.subnet.id
    route_table_id = module.public_route_table.rt.id
  
}

/*
  module that  creates security
  groups with given list of
  ingress routes and egress routes,
  attach it to given vpc
  and given name in tag
*/

module "tf_practice_instance_sg_1"{
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc.id
  ingress_routes = [
    {
      "cidr_blocks" : [var.default_cidr ],
      "description" : "allow ssh",
      "from_port" : 22,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "tcp",
      "security_groups" : null,
      "self" : null,
      "to_port" : 22
    },
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
  name = "tf_practice_instance_sg_1"
}

/*
  module that  creates ec2 instance
  from given ami id, provided instance
  type, subnet_id, list of security_groups
  to attach
*/

module "webserver" {
  source = "./modules/instance"
  ami_id = "ami-00197740b3806d968"
  instance_type = "t2.micro"
  associate_public_ip = true
  subnet_id = module.public_subnet.subnet.id
  tf_instance_ip_address = var.tf_instance_ip_address
  security_groups = [module.tf_practice_instance_sg_1.sg.id]
}

output "webserver" {
  value = module.webserver.instance.public_ip
}
