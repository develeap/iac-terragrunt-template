data "tls_certificate" "github" {
  url = "https://${var.github_url}/.well-known/openid-configuration"
}

data "http" "machine_public_ip" {
  url    = "http://ipv4.icanhazip.com/"
  method = "GET"
}

data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "assume_role_with_web_identity_trust_policy" {
  statement {
    effect = "Allow"
    sid    = "GitHubIdpTrustPolicy"
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.github_url}"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${var.github_url}:sub"
      values = [
        "repo:smipin/infrastructure:ref:refs/heads/feature/terraform"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "${var.github_url}:aud"
      values   = ["${local.aws_sts}"]
    }
  }

  statement {
    effect = "Allow"
    sid    = "TrustAdminMachinePolicy"
    principals {
      type        = "AWS"
      identifiers = ["${data.aws_caller_identity.current.arn}"]
    }

    actions = ["sts:AssumeRole"]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values = [
        "${chomp(data.http.machine_public_ip.response_body)}/32"
      ]
    }

  }
}