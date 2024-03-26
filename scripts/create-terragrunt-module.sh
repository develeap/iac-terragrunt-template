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

  module_name=$1
  module_path=$(fuzzy_select)
  if [[ -z $module_path ]]; then
    echo "Module path not provided."
    return 2
  fi
  full_path="${module_path}/${module_name}"
  echo "Creating Terragrunt module at: ${full_path}"
  if mkdir -p "${full_path}" && create_template_file "${full_path}"; then
    echo "Directory created and template file created successfully."
  else
    echo "Failed to create directory or template file."
    return 3
  fi

}

# /**
# * @brief This function generates a Terragrunt manifest file with the required structure.
# * @param {string} $1 - The module path.
# * @param {string} $2 - The path.
# * @return - None
create_template_file() {
	if [[ -z $1 ]]; then
		echo "Path not provided."
		return 1
	fi

	path=$1
	cat <<HCL > "${path}"/terragrunt.hcl
# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform and OpenTofu that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  #source = "tfr://registry.terraform.io/terraform-aws-modules/ec2-instance/aws?version=5.6.1"
  #source = "tfr://registry.opentofu.io/terraform-aws-modules/ec2-instance/aws?version=5.6.1"
  #source = "git::git@github.com:acme/infrastructure-modules.git//networking/vpc?ref=v0.0.1"
  source = "\${get_path_to_repo_root()}//modules/"

  before_hook "before_hook" {
    commands = ["apply", "plan"]
    execute = [
      "echo",
      "==========================================================================   ",
      "Running Terrafom",
      "   =========================================================================="
    ]
  }
  
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
  error_hook "error_hook" {
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

# /**
# * @brief This function uses fzf to select the path of the module.
# * @param - None
# * @return - Selected path
# */
fuzzy_select() {
    root_dir="infrastructure-live"

    # Get list of accounts
    accounts=$(find "$root_dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | fzf --prompt="Select Account: ")
    if [[ -z "$accounts" ]]; then
        echo "No account selected. Exiting."
        exit 1
    fi

    # Get list of environments
    environments=$(find "$root_dir/$accounts" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | fzf --prompt="Select Environment: ")
    if [[ -z "$environments" ]]; then
        echo "No environment selected. Exiting."
        exit 1
    fi

    # Get list of sub-environments
    sub_environments=$(find "$root_dir/$accounts/$environments" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | fzf --prompt="Select Sub Environment: ")
    if [[ -z "$environments" ]]; then
        echo "No environment selected. Exiting."
        exit 1
    fi


    # Get list of regions
    regions=$(find "$root_dir/$accounts/$environments/$sub_environments" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | fzf --prompt="Select Region: ")
    if [[ -z "$regions" ]]; then
        echo "No region selected. Exiting."
        exit 1
    fi

    # Get list of infrastructure components
    components=$(find "$root_dir/$accounts/$environments/$sub_environments/$regions" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | fzf --prompt="Select Component: ")
    if [[ -z "$components" ]]; then
        echo "No component selected. Exiting."
        exit 1
    fi

    # Construct full path
    selected_path="$root_dir/$accounts/$environments/$sub_environments/$regions/$components"
    # return "${selected_path}"
    echo "${selected_path}"
}

###########
#  Main   #
###########
main() {
	create_terragrunt_file "$1"
}

main "$1"
