terraform_version_constraint  = ">= 1.6.6"
terragrunt_version_constraint = ">= 0.54.12"

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
    LastModifiedTime = "${timestamp()}", // uncomment only after delivery
    #LastModifiedBy   = "${get_aws_caller_identity_arn()}"
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
  compliance_tags = tomap({
    Owner      = "Lior Dux",
    Birthdate  = "${timestamp()}",
    Objective  = "Digger with Terragrunt",
    Expiration = "${timeadd(timestamp(), "24h")}",
    Name       = "Lior Dux"
  })
  tags_all = jsonencode(merge(
    local.tg_tags,
    local.computed_tags,
    local.account_tags,
    local.region_tags,
    local.env_tags,
    local.compliance_tags
  ))
  provider_a = <<-PROVIDER_A
  provider "aws" {
    region  = "${local.region}"
    profile = "${local.profile}"

    assume_role {
      role_arn = "arn:aws:iam::${local.account_id}:role/${local.env}.terraform_bot.role"
      #policy_arns   = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      session_name = "Local-Session"
      duration     = "0h20m0s"
    }

    # Only these AWS Account IDs may be operated on by this template
    allowed_account_ids = ["${local.account_id}"]

    default_tags {
      tags = ${local.tags_all}
    }
  }
  PROVIDER_A
  provider_b = <<-PROVIDER_B
  provider "aws" {
    region  = "${local.region}"

    # Web Identity Role Federation only used in CI/CD
  # assume_role_with_web_identity {
  #    role_arn           = "arn:aws:iam::${local.account_id}:role/${local.env}.terraform_bot.role"
  #    session_name       = "Pipeline-Session"
  #    duration           = "0h20m0s"
  #    web_identity_token = get_env("AWS_SESSION_TOKEN", "")
  #  }
    assume_role {
      role_arn = "arn:aws:iam::${local.account_id}:role/${local.env}.terraform_bot.role"
      session_name = "Pipeline-Session"
      duration     = "0h20m0s"
    }



    # Only these AWS Account IDs may be operated on by this template
    allowed_account_ids = ["${local.account_id}"]

    default_tags {
      tags = ${local.tags_all}
    }
  }
  PROVIDER_B
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  # Provider will be generated dynamically according to where it is running
  # If running locally, it will use the assume_role block 
  # If running in CI/CD, it will use the assume_role_with_web_identity block
  contents = get_env("GITHUB_ACTIONS") == "true" ? "${local.provider_b}" : "${local.provider_a}"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket  = "${local.env}.${local.account_id}-terraform-remote-state.s3"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    profile = "${local.profile}"
    region  = "${local.region}"

    # Uncomment the following if your using a custom endpoint
    #endpoint       = "https://s3.eu-central-1.amazonaws.com"

    encrypt        = true
    kms_key_id     = "${local.kms_key_id}"
    dynamodb_table = "${local.env}.terraform_remote-state-lock.dynamodb"
    assume_role = {
      role_arn = "arn:aws:iam::${local.account_id}:role/${local.env}.terraform_bot.role"
      #external_id  = "terraform-${local.env}"
      session_name = "Local-Session"
    }
    s3_bucket_tags      = jsondecode("${local.tags_all}")
    dynamodb_table_tags = jsondecode("${local.tags_all}")
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
