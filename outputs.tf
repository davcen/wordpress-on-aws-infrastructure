output "alb_public_dns" {
  description = "The DNS Name of public Application Load Balancer"
  value       = module.alb.this_lb_dns_name
}

output "db_endpoint" {
  description = "The endpoint of RDS Aurora cluster"
  value       = module.wp_db.this_rds_cluster_endpoint
}

output "wordpress_ecs_task_definition_arn" {
  description = "The ARN of ECS task definition"
  value       = aws_ecs_task_definition.wordpress.arn
}
