module "ecs_task_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  vpc_id          = module.vpc.vpc_id
  name            = "${var.name_prefix}-ecs-task-sg"
  use_name_prefix = false
  description     = "Access to public Application Load Balancer"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      description              = "Connections and Health Checks from Application Load Balancer"
      source_security_group_id = module.alb_sg.this_security_group_id
    }
  ]

  number_of_computed_ingress_with_source_security_group_id = 1

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = var.common_tags
}

resource "aws_ecs_cluster" "wp" {
  name = "${var.name_prefix}-fargate-cluster"
}

resource "aws_ecs_service" "wp" {
  name    = "${var.name_prefix}-fargate-service"
  cluster = aws_ecs_cluster.wp.id

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  task_definition = aws_ecs_task_definition.wordpress.arn

  desired_count = var.task_desired_count

  network_configuration {
    security_groups = [
      module.efs_sg.this_security_group_id,
      module.ecs_task_sg.this_security_group_id
    ]
    subnets = module.vpc.private_subnets
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0] // register to "blue" target by default
    container_name   = var.container_name
    container_port   = var.container_port
  }

  tags = var.common_tags

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_appautoscaling_target" "wp-service" {
  min_capacity       = var.ecs_service_autoscaling_min_capacity
  max_capacity       = var.ecs_service_autoscaling_max_capacity
  resource_id        = "service/${aws_ecs_cluster.wp.name}/${aws_ecs_service.wp.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "wp-service" {
  name               = "${var.name_prefix}.fargate-service-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.wp-service.id
  scalable_dimension = aws_appautoscaling_target.wp-service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.wp-service.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.ecs_service_autoscaling_cpu_average_utilization_target
    scale_in_cooldown  = var.ecs_service_autoscaling_scale_in_cooldown
    scale_out_cooldown = var.ecs_service_autoscaling_scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_ecs_task_definition" "wordpress" {
  family                   = "${var.name_prefix}-wordpress"
  execution_role_arn       = module.ecs_task_execution_role.this_iam_role_arn
  task_role_arn            = module.ecs_task_role.this_iam_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  container_definitions = templatefile(
    "wordpress_container_definition.json",
    {
      db_user         = aws_ssm_parameter.db_master_user.arn,
      db_password     = aws_ssm_parameter.db_master_password.arn,
      db_host         = module.wp_db.this_rds_cluster_endpoint,
      container_image = var.container_image_url,
      container_name  = var.container_name,
      container_port  = var.container_port,
      log_group       = aws_cloudwatch_log_group.wordpress.name,
      region          = data.aws_region.current.name
    }
  )

  volume {
    name = "efs"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.persistent_data.id
    }
  }
}

resource "aws_cloudwatch_log_group" "wordpress" {
  name              = "/${var.name_prefix}/wp-task"
  tags              = var.common_tags
  retention_in_days = var.log_retention_in_days
}
