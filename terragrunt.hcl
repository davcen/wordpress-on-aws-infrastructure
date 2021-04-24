locals {
  project_name = "wp-on-aws"
  region       = "eu-west-1"
  environment  = "dev"

  common_tags = {
    "Project"     = local.project_name
    "CreatedBy"   = "Terraform"
    "ManagedBy"   = "Terraform"
    "Environment" = local.environment
  }

  name_prefix = lower("${local.environment}-${local.project_name}")
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "${local.name_prefix}-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "${local.name_prefix}-terraform-state-locks"
  }
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "skip"
  contents  = <<EOF
terraform {
  backend "s3" {
  }
}
EOF
}

generate "provider" {
  path      = "providers.tf"
  if_exists = "skip"
  contents  = <<EOF
provider "aws" {
  region = var.region
}
EOF
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "skip"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.14"
}
EOF
}

inputs = {
  region      = local.region
  account_id  = get_aws_account_id()
  environment = local.environment
  common_tags = local.common_tags
  name_prefix = local.name_prefix

  vpc_cidr = "10.0.0.0/16"

  public_subnets = [
    "10.0.0.0/22",
    "10.0.4.0/22",
    "10.0.8.0/22"
  ]

  private_subnets = [
    "10.0.32.0/21",
    "10.0.40.0/21",
    "10.0.48.0/21"
  ]

  database_subnets = [
    "10.0.64.0/23",
    "10.0.66.0/23",
    "10.0.68.0/23"
  ]

  db_master_username = "admin"
  db_master_password = "password"

  task_cpu    = 1024
  task_memory = 2048

  log_retention_in_days = 30

  container_name = "wordpress"
  container_port = 80
}