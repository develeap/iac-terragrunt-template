###################
# Terraforme Role #
###################
# Create an AWS IAM Role for Github to assume in order to provision infra using terraform.
resource "aws_iam_role" "role" {
  name                = var.role_name
  assume_role_policy  = var.assume_role_policy
  managed_policy_arns = local.managed_policy_arns
}