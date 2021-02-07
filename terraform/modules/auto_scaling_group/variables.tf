variable "name" {
    type = string
}

variable "max_size" {
    type =  number
}

variable "min_size" {
    type = number
}

variable "health_check_type" {
    type = string
}

variable "desired_capacity" {
    type = number
}

variable "force_delete" {
    type = bool
}

variable "launch_template_id" {
    type = string
}

variable "availability_zones" {
    type =  list(string)
}

// variable "load_balancers" {
//     type = list(string)
// }

variable "target_group_arns" {
    type = list(string)
}