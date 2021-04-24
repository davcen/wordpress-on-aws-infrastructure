variable "region" {}

variable "environment" {}

variable "name_prefix" {}

variable "common_tags" {
  type = map(string)
}

variable "vpc_cidr" {}

variable "private_subnets" {
  type = list(string)
}

variable "database_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "db_master_username" {
  sensitive = true
}

variable "db_master_password" {
  sensitive = true
}

variable "task_cpu" {}

variable "task_memory" {}

variable "log_retention_in_days" {}

variable "container_name" {}
variable "container_port" {}
