provider "aws" {
  region  = "${local.region}"
  profile = "${local.profile}"

  # Web Identity Role Federation only used in CI/CD
  assume_role_with_web_identity {
    role_arn           = "arn:aws:iam::${local.account_id}:role/${local.env}.terraform_bot.role"
    session_name       = "Pipeline-Session"
    duration           = "0h20m0s"
    web_identity_token = get_env("AWS_SESSION_TOKEN", "")
  }

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]

  default_tags {
    # Use heredoc syntax to render the json to avoid quoting complications.
    tags = "${local.tags_all}"
  }
}
