module "efs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  vpc_id          = module.vpc.vpc_id
  name            = "${var.name_prefix}-efs-sg"
  use_name_prefix = false
  description     = "Access to EFS for Wordpress persistent data"

  ingress_with_self = [
    {
      rule        = "nfs-tcp"
      description = "All resources attached to this security group"
    }
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = var.common_tags
}

resource "aws_efs_file_system" "persistent_data" {
  creation_token = "${var.name_prefix}-persistent-data"
  tags           = var.common_tags
}

resource "aws_efs_mount_target" "persistent_data" {
  count          = length(module.vpc.private_subnets)
  file_system_id = aws_efs_file_system.persistent_data.id
  subnet_id      = module.vpc.private_subnets[count.index]
  security_groups = [
    module.efs_sg.this_security_group_id
  ]
}
