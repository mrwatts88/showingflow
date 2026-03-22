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
  github_oidc_url                  = "https://token.actions.githubusercontent.com"
  github_repository                = "mrwatts88/showingflow"
  github_main_branch               = "repo:mrwatts88/showingflow:ref:refs/heads/main"
  billing_alert_email              = "mattryanwatts@gmail.com"
  monthly_billing_budget_amount    = "25"
  anomaly_alert_absolute_threshold = "5"
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
      "ce:GetAnomalyMonitors",
      "ce:GetAnomalySubscriptions"
    ]
    resources = [
      aws_ce_anomaly_monitor.services.arn,
      aws_ce_anomaly_subscription.daily_email.arn
    ]
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

resource "aws_budgets_budget" "monthly_cost" {
  name         = "showingflow-monthly-cost"
  budget_type  = "COST"
  limit_amount = local.monthly_billing_budget_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = [local.billing_alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "FORECASTED"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = [local.billing_alert_email]
  }
}

resource "aws_ce_anomaly_monitor" "services" {
  name              = "showingflow-service-anomaly-monitor"
  monitor_dimension = "SERVICE"
  monitor_type      = "DIMENSIONAL"
}

resource "aws_ce_anomaly_subscription" "daily_email" {
  name             = "showingflow-daily-anomaly-email"
  frequency        = "DAILY"
  monitor_arn_list = [aws_ce_anomaly_monitor.services.arn]

  subscriber {
    address = local.billing_alert_email
    type    = "EMAIL"
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      match_options = ["GREATER_THAN_OR_EQUAL"]
      values        = [local.anomaly_alert_absolute_threshold]
    }
  }
}
