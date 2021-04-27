module "wp_db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "4.3.0"

  name              = "${var.name_prefix}-wp-db"
  engine            = "aurora-mysql"
  engine_mode       = "serverless"
  storage_encrypted = true

  vpc_id                  = module.vpc.vpc_id
  subnets                 = module.vpc.database_subnets
  db_subnet_group_name    = module.vpc.database_subnet_group_name
  allowed_security_groups = [module.ecs_task_sg.this_security_group_id]

  replica_scale_enabled = false
  replica_count         = 0

  db_parameter_group_name         = aws_db_parameter_group.aurora_mysql.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_mysql.id

  database_name          = "wordpress"
  create_random_password = false
  username               = var.db_master_username
  password               = var.db_master_password

  apply_immediately   = true
  skip_final_snapshot = true

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = var.db_min_capacity
    max_capacity             = var.db_max_capacity
    seconds_until_auto_pause = var.db_autopause_after_seconds
    timeout_action           = "RollbackCapacityChange"
  }

  create_monitoring_role = false

  tags = var.common_tags
}

resource "aws_db_parameter_group" "aurora_mysql" {
  name        = "${var.name_prefix}-aurora-db-mysql-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${var.name_prefix}-aurora-db-mysql-parameter-group"
  tags        = var.common_tags
}

resource "aws_rds_cluster_parameter_group" "aurora_mysql" {
  name        = "${var.name_prefix}-aurora-mysql-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${var.name_prefix}-aurora-mysql-cluster-parameter-group"
  tags        = var.common_tags
}

resource "aws_ssm_parameter" "db_master_user" {
  name  = "/${var.name_prefix}/db_master_user"
  type  = "SecureString"
  value = var.db_master_username
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "db_master_password" {
  name  = "/${var.name_prefix}/db_master_password"
  type  = "SecureString"
  value = var.db_master_password
  tags  = var.common_tags
}
