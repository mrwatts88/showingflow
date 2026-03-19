terraform {
  backend "s3" {
    bucket       = "showingflow-terraform-state-409415529879-us-east-2"
    key          = "infra/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

locals {
  github_oidc_url    = "https://token.actions.githubusercontent.com"
  github_repository  = "mrwatts88/showingflow"
  github_main_branch = "repo:mrwatts88/showingflow:ref:refs/heads/main"
}

data "tls_certificate" "github_actions" {
  url = local.github_oidc_url
}

resource "aws_ecr_repository" "showingflow_api" {
  name                 = "showingflow-api"
  image_tag_mutability = "MUTABLE"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = local.github_oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.github_main_branch]
    }
  }
}

resource "aws_iam_role" "github_actions_ecr_push" {
  name               = "github-actions-showingflow-ecr-push"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

data "aws_iam_policy_document" "github_actions_ecr_push" {
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [aws_ecr_repository.showingflow_api.arn]
  }
}

resource "aws_iam_role_policy" "github_actions_ecr_push" {
  name   = "github-actions-showingflow-ecr-push"
  role   = aws_iam_role.github_actions_ecr_push.id
  policy = data.aws_iam_policy_document.github_actions_ecr_push.json
}

resource "aws_iam_role" "github_actions_terraform_plan" {
  name               = "github-actions-showingflow-terraform-plan"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

data "aws_iam_policy_document" "github_actions_terraform_plan" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::showingflow-terraform-state-409415529879-us-east-2"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::showingflow-terraform-state-409415529879-us-east-2/infra/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:DescribeRepositories",
      "ecr:ListTagsForResource"
    ]
    resources = [aws_ecr_repository.showingflow_api.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:GetOpenIDConnectProvider"
    ]
    resources = [aws_iam_openid_connect_provider.github_actions.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies"
    ]
    resources = [
      aws_iam_role.github_actions_ecr_push.arn,
      aws_iam_role.github_actions_terraform_plan.arn
    ]
  }
}

resource "aws_iam_role_policy" "github_actions_terraform_plan" {
  name   = "github-actions-showingflow-terraform-plan"
  role   = aws_iam_role.github_actions_terraform_plan.id
  policy = data.aws_iam_policy_document.github_actions_terraform_plan.json
}
