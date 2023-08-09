variable "service_prefix" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = map(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  type = map(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "ecs_api_tag" {
  type = string
}

variable "ecs_api_count" {
  type = number
}
