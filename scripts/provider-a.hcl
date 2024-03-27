provider "aws" {
  region  = "${local.region}"
  profile = "${local.profile}"

  assume_role {
    role_arn      = "arn:aws:iam::${local.account_id}:role/${local.env}.terraform_bot.role"
    #policy_arns   = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    session_name  = "Local-Session"
    duration = "0h20m0s"
  }

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]

  default_tags {
    # Use heredoc syntax to render the json to avoid quoting complications.
    tags = ${local.tags_all}
  }
}
