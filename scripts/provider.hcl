locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  
  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.account_id
  profile      = try(local.account_vars.locals.profile, "default")
  kms_key_id   = local.account_vars.locals.kms_key_id
  region       = local.region_vars.locals.region
  env          = local.environment_vars.locals.env

  # TAGS
  tg_tags = tomap({ Terragrunt = "True" })
  computed_tags = tomap({
    # LastModifiedTime = "${timestamp()}" // uncomment only after delivery
    # LastModifiedBy   = "${get_aws_caller_identity_arn()}"
  })
  account_tags = tomap({
    AccountName = "${local.account_name}",
    AccountId   = "${local.account_id}"
  })
  region_tags = tomap({
    Region = "${local.region}"
  })
  env_tags = tomap({
    Environment = "${local.env}"
  })
  tags_all = jsonencode(merge(
    local.tg_tags,
    local.computed_tags,
    local.account_tags,
    local.region_tags,
    local.env_tags,
  ))
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<-PRODIVER
  provider "aws" {
    region  = "${local.region}"
    profile = "${local.profile}

    assume_role {
      role_arn      = "arn:aws:iam::"${local.account_id}":role/${local.env}.terraform_bot.role"
      policy_arns   = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      session_name  = "Local-Session"
      duration = 0h20m0s
    }

    # Only these AWS Account IDs may be operated on by this template
    allowed_account_ids = ["${local.account_id}"]

    default_tags {
      # Use heredoc syntax to render the json to avoid quoting complications.
      tags = jsondecode(
      <<-TAGS
      ${local.tags_all}
      TAGS
      )
    }
  }
  PRODIVER
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = "${local.env}.terraform-remote-state.s3"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    profile        = "${local.profile}"
    region         = "${local.region}"
    encrypt        = true
    kms_key_id     = "${local.kms_key_id}"
    dynamodb_table = "${local.env}.terraform_remote_state_lock.dynamodb"
    assume_role = {
      role_arn      = "arn:aws:iam::"${local.account_id}":role/${local.env}.terraform_bot.role"
      session_name  = "Local-Session"
      duration = 0h20m0s
    }
    s3_bucket_tags = "${local.tags_all}" 
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)