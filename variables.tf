variable "region" {}

variable "account_id" {}

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

variable "db_min_capacity" {}
variable "db_max_capacity" {}
variable "db_autopause" {}
variable "db_autopause_after_seconds" {}

variable "task_cpu" {}
variable "task_memory" {}
variable "task_desired_count" {}

variable "log_retention_in_days" {}

variable "container_image_url" {}
variable "container_name" {}
variable "container_port" {}

variable "ecs_service_autoscaling_min_capacity" {}
variable "ecs_service_autoscaling_max_capacity" {}
variable "ecs_service_autoscaling_cpu_average_utilization_target" {}
variable "ecs_service_autoscaling_scale_in_cooldown" {}
variable "ecs_service_autoscaling_scale_out_cooldown" {}
