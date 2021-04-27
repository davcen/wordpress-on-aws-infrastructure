resource "aws_codebuild_project" "wordpress-cd" {
  name         = "${var.name_prefix}-wordpress-cd"
  description  = "Build custom docker image based on Wordpress official"
  service_role = module.codebuild_servicerole.this_iam_role_arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_REGION"
      value = var.region
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.account_id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.wordpress.name
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_application_repository_url
    git_clone_depth = 1
  }

  tags = var.common_tags
}

resource "aws_codebuild_source_credential" "application-repo" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_access_token
}
