module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"

  name = "${var.name_prefix}-vpc"
  cidr = var.vpc_cidr
  azs  = data.aws_availability_zones.this.names

  enable_dns_hostnames = true

  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  tags = var.common_tags
}
