# Rif. https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html

data "aws_iam_policy_document" "ecs_task_execution_policy" {
  statement {
    sid = "AmazonECSTaskExecutionRolePolicy"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ssm:GetParameters",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

module "ecs_task_execution_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "3.16.0"

  name        = "${var.name_prefix}-ecs-task-execution"
  description = "Amazon ECS Task Execution Role Policy"
  policy      = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

module "ecs_task_execution_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "3.16.0"

  role_name         = "${var.name_prefix}-ecs-task-execution"
  create_role       = true
  role_requires_mfa = false

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  custom_role_policy_arns = [
    module.ecs_task_execution_policy.arn
  ]

  number_of_custom_role_policy_arns = 1
}

data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    sid = "AmazonECSTaskExecutionRolePolicy"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]
    resources = [aws_efs_file_system.persistent_data.arn]
  }
}

module "ecs_task_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "3.16.0"

  name        = "${var.name_prefix}-ecs-task"
  description = "Amazon ECS Task Role Policy"
  policy      = data.aws_iam_policy_document.ecs_task_policy.json
}

module "ecs_task_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "3.16.0"

  role_name         = "${var.name_prefix}-ecs-task"
  create_role       = true
  role_requires_mfa = false

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  custom_role_policy_arns = [
    module.ecs_task_policy.arn
  ]

  number_of_custom_role_policy_arns = 1
}


# Rif. https://docs.aws.amazon.com/codebuild/latest/userguide/setting-up.html#setting-up-service-role

data "aws_iam_policy_document" "codebuild_service_role_policy" {
  statement {
    sid = "CloudWatchLogsPolicy"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid = "ECRRWPolicy"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = ["*"]
  }
}

module "codebuild_servicerole_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "3.16.0"

  name        = "${var.name_prefix}-codebuild-servicerole"
  description = "AWS CodeBuild Service Role Policy"
  policy      = data.aws_iam_policy_document.codebuild_service_role_policy.json
}

module "codebuild_servicerole" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "3.16.0"

  role_name         = "${var.name_prefix}-codebuild-servicerole"
  create_role       = true
  role_requires_mfa = false

  trusted_role_services = [
    "codebuild.amazonaws.com"
  ]

  custom_role_policy_arns = [
    module.codebuild_servicerole_policy.arn
  ]

  number_of_custom_role_policy_arns = 1
}
