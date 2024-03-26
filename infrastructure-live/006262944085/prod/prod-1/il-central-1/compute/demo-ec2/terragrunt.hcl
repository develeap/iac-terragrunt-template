# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform and OpenTofu that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/ec2-instance/aws?version=5.6.1"

  before_hook "before_hook" {
    commands = ["apply", "plan"]
    execute = [
      "echo",
      "\n\t=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n",
      "\t==========================================================================Running Terrafom==========================================================================\n",
      "\t-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n"
    ]
  }

  after_hook "after_hook" {
    commands     = ["apply", "plan"]
    run_on_error = true
    execute = [
      "echo",
      "\n\tnnununununununununununununununununununununununununununununununnununununununununununununununununununununununununununununununnunununununununununununununununununununu\n",
      "\t===================================================================Finished Running Terrafom=======================================================================\n",
      "\tunununununununununununununununununununununununununununununununnununununununununununununununununununununununununununununununnunununununununununununununununununununu\n"
    ]
  }

  # After an error occurs during apply or plan, run "echo Error Hook executed". This hook is configured so that it will run
  # after any error, with the ".*" expression.
  error_hook "error_hook" {
    commands  = ["apply", "plan"]
    on_errors = [".*"]
    execute = [
      "echo",
      "\n\t^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^\n",
      "\t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ERROR !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n",
      "\t^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^\n"
    ]
  }

  # For any terraform commands that use locking, make sure to configure a lock timeout of 20 minutes.
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=20m"]
  }
}

# Include the root 'terragrunt.hcl' configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "provider" {
  path = find_in_parent_folders("provider.hcl")
  # We want to reference the variables from the included config in this configuration, so we expose it.
  expose = true
}

locals {
  env = "prod"
}

inputs = {
  #name = "${local.environment_vars.locals.evn}.demo-instance.ec2"
  name = "${local.env}.demo-instance.ec2"
  instance_type          = "t3.micro"
  vpc_security_group_ids = ["sg-03a28927b740df64e"]
  subnet_id              = "subnet-075ffae68d9b0487a"
}
