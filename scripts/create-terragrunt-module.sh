#!/bin/bash set-ex
###########################################################################################
# Author: Lior Dux @zMynxx
# Description: This script generates a Terragrunt manifest file with the required structure.
# Usage: ./create-tg-file.sh <resource-name> 
# Example: ./create-tg-file.sh s3
# Dependencies: None
# License: MIT
# Version: 1.0
###########################################################################################

# /**
# * @brief This function generates a Terraform module structure with the required files.
# * @param {string} $1 - The name of the module to create.
# * @return - None
# */
create_terragrunt_file() {
	if [[ -z $1 ]]; then
		echo "Module name not provided."
		return 1
	fi

	modules_dir="modules"
	module_name=$1
	module_path=

}

# /**
# * @brief This function generates a Terragrunt manifest file with the required structure.
# * @param {string} $1 - The module path.
# * @param {string} $2 - The path.
# * @return - None
create_template_file() {
	if [[ -z $1 ]]; then
		echo "Module path not provided."
		return 1
	fi

	module_path=$1
	module_name=$2
	cat <<-HCL > "${module_path}"/"${module_name}"/terragrunt.hcl
  # ---------------------------------------------------------------------------------------------------------------------
  # TERRAGRUNT CONFIGURATION
  # This is the configuration for Terragrunt, a thin wrapper for Terraform and OpenTofu that helps keep your code DRY and
  # maintainable: https://github.com/gruntwork-io/terragrunt
  # ---------------------------------------------------------------------------------------------------------------------

	terraform {
	  #source = "tfr:///aws-ia/eks-blueprints-addon/aws?version=1.1.0"
	  #source = "git::git@github.com:acme/infrastructure-modules.git//networking/vpc?ref=v0.0.1"
	  source = "\${get_path_to_repo_root()}//modules/"

    # Before apply or plan, run "echo Foo".
    before_hook "before_hook" {
      commands = ["apply", "plan"]
      execute = [
        "echo",
        "==========================================================================   ",
        "Running Terrafom",
        "   =========================================================================="
        ]
    }
    
    # After apply or plan, run "echo Foo"
    after_hook "after_hook" {
      commands = ["apply", "plan"]
      run_on_error = true
      execute = [
        "echo",
        "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^   ",
        "Finished Running Terrafom",
        "   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
      ]
    }
    
    # After an error occurs during apply or plan, run "echo Error Hook executed". This hook is configured so that it will run
    # after any error, with the ".*" expression.
    error_hook "error_hook_1" {
      commands  = ["apply", "plan"]
      on_errors = [".*"]
      execute = [
        "echo",
        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  ",
        "Finished Running Terrafom",
        "   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
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

  dependencies {
    paths = []
  }

  dependency "public_hosted_zone" {
    config_path = ""
    mock_outputs = {}
  }

  inputs = {}
	HCL
}

###########
#  Main   #
###########
main() {
	create_terragrunt_file "$1"
}

main "$1"
