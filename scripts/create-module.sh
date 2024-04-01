#!/bin/bash set-ex
###########################################################################################
# Author: Lior Dux @zMynxx
# Description: This script generates a Terraform module structure with the required files.
# Usage: ./create-module.sh <module_name>
# Example: ./create-module.sh my-module
# Dependencies: None
# License: MIT
# Version: 1.0
###########################################################################################

# /**
# * @brief This function generates a Terraform module structure with the required files.
# * @param {string} $1 - The name of the module to create.
# * @return - None
# */
create_module() {
	modules_dir="modules"
	module_name=$1
	module_path="${modules_dir}"/"${module_name}"
	mkdir -p "${module_path}" || return 1

	# Create a versions template for this module
	cat <<-TF >"${module_path}"/0-versions.tf
	terraform {
		required_version = ">= $(terraform --version | head -1 | awk '{print $2}' | sed 's/v//' | sed 's/+.*//')"
	}
	TF

	# Create a main.tf file for this module
	cat <<-TF >"${module_path}/1-main.tf"
	resource "null_resource" "example" {
		# Paramaters
	}
	TF

	# Create a outputs.tf file for this module
	cat <<-TF >"${module_path}/2-outputs.tf"
	output "example" {
		value = null_resource.example.*
	}
	TF

	# Create a locals.tf file for this module
	cat <<-TF >"${module_path}/3-locals.tf"
	locals {
		# Variables
	}
	TF

	# Create a data_sources.tf file for this module
	cat <<-TF >"${module_path}/4-data_sources.tf"
	data "example" {
		# Paramaters
	}
	TF

	# Create a variables.tf file for this module
	cat <<-TF >"${module_path}/5-variables.tf"
	variable "example" {
		type = string
	}
	TF
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
	create_module "${module_name}"
}

main "$1"
