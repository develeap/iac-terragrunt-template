locals {
  aws_sts             = "sts.amazonaws.com"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  tags_all = merge(
    var.tags,
    { Terraform = "True", Name = "${var.role_name}" }
  )
}