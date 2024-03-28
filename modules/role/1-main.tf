###################
# Terraforme Role #
###################
# Create an AWS IAM Role for Github to assume in order to provision infra using terraform.
resource "aws_iam_role" "role" {
  name                  = var.name
  assume_role_policy    = var.assume_role_policy
  managed_policy_arns   = var.managed_policy_arns
  description           = var.description
  force_detach_policies = var.force_detach_policies
  dynamic "inline_policy" {
    for_each = var.inline_policy != null ? [var.inline_policy] : []
    content {
      name   = "${var.name}-inline-policy"
      policy = var.inline_policy
    }
  }
  max_session_duration = var.max_session_duration
  # name_prefix           = var.name_prefix
  path                 = var.path
  permissions_boundary = var.permissions_boundary
  tags                 = var.tags
}