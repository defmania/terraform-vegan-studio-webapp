variable "vpc_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "public_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "igw_name" {
  type = string
}

variable "nat_subnet_key" {
  type        = string
  description = "Key from public_subnets map to place the NAT Gateway"
}

