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
	cp scripts/terragrunt-template.hcl "${path}"/terragrunt.hcl
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
  module_name=$1
  if [[ -z "${module_name}" ]]; then
    echo "Module name not provided."
    read -r -p "Enter the module name: " module_name 
  fi
	create_terragrunt_file "${module_name}"
}

main "$1"
