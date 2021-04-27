resource "aws_ecr_repository" "wordpress" {
  name = "${var.name_prefix}-wordpress"

  tags = var.common_tags
}

data "aws_iam_policy_document" "ecr_repository_policy" {
  statement {
    sid = "CodeBuildAccess"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

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
  }
}

resource "aws_ecr_repository_policy" "wordpress" {
  repository = aws_ecr_repository.wordpress.name

  policy = data.aws_iam_policy_document.ecr_repository_policy.json
}
