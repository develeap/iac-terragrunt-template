#!/bin/bash set -ex
###########################################################################################
# Author: Lior Dux @zMynxx
# Description: This script generates a README.md and EXAMPLE.md file for a Terraform module.
# Usage: ./create-docs.sh <module_name>
# Example: ./create-docs.sh my-module
# Dependencies: terraform-docs
# License: MIT
# Version: 1.0
###########################################################################################

###########
# Globals #
###########
modules_dir="modules"

#############
# Functions #
#############

# /**
# * @brief This function generates an EXAMPLE.md file for a Terraform module.
# * @param {string} $1 - The name of the module to create an EXAMPLE.md file for.
# * @return - None
# */
create_example_markdown() {
	if [[ -z $1 ]]; then
		echo "Module name not provided."
		return 1
	fi

	module_name="$1"
	module_path="${modules_dir}"/"${module_name}"
	example_file="${module_path}"/EXAMPLE.md

	if [[ -f "${example_file}" ]]; then
		echo "EXAMPLE.md file already exists in the module directory."
		return 1
	fi

	# init repo if not initiate already (required for docs)
	cd "${module_path}"
	terraform init
	cd -
	# Generate example configuration using terraform-docs
	example_config=$(terraform-docs tfvars hcl "${module_path}")

	# Create the example.md file with the desired structure
	cat <<-EOF >"${example_file}"
	module "${module_name}" {
	  $(echo 'source = "../../path/to/this/module"' | awk '{print "  " $0}')

	  $(echo "$example_config" | awk '{print "  " $0}')
	}
	EOF
}

# /**
# * @brief This function generates a README.md file for a Terraform module.
# * @param {string} $1 - The name of the module to create a README.md file for.
# * @return - None
# */
create_docs_markdown() {
	if [[ -z $1 ]]; then
		echo "Module name not provided."
		return 1
	fi

	module_name="$1"
	module_path="${modules_dir}/${module_name}"
	readme_file="${module_path}"/README.md

	if [ -f "${readme_file}" ]; then
		echo "README.md file already exists in the module directory."
		return 1
	fi

	# Set header
	echo "# Module \"${module_name}\"" >>"${readme_file}"
	echo "---" >>"${readme_file}"

	cat <<-EOFTABLE >>"${readme_file}"
	- [Module \"${module_name}\"](#${module_name})
	- [Usage](#usage)
	- [Docs](#docs)
	- [Requirements](#requirements)
	- [Providers](#providers)
	- [Modules](#modules)
	- [Resources](#resources)
	- [Inputs](#inputs)
	- [Outputs](#outputs)
	- [Graph](#graph)"
	EOFTABLE
	echo "" >>"${readme_file}"

	# Set header
	echo "# Usage" >>"${readme_file}"
	echo "---" >>"${readme_file}"
	echo "Paste the following snipped into your code to use the module." >>"${readme_file}"

	# Paste in the example in code block
	example_file="$${module_path}/EXAMPLE.md"
	echo '```terraform' >>"${readme_file}"
	cat "${example_file}" >>"${readme_file}"
	echo '```' >>"${readme_file}"

	echo "" >>"${readme_file}"
	echo "Run <kbd>terraform init</kbd> to initialize the module." >>"${readme_file}"
	echo "" >>"${readme_file}"
	echo "Run <kbd>terraform plan</kbd> to create the execution plan." >>"${readme_file}"
	echo "" >>"${readme_file}"
	echo "Run <kbd>terraform apply</kbd> to create the resources." >>"${readme_file}"
	echo "" >>"${readme_file}"
	echo "Run <kbd>terraform destroy</kbd> to destroy the resources." >>"${readme_file}"
	echo "" >>"${readme_file}"

	# Add a separator between the generated documentation and the Terraform graph
	echo -e "\n---\n" >>"${readme_file}"

	# Set header
	echo "# Docs" >>"${readme_file}"
	echo "---" >>"${readme_file}"

	# Run terraform-docs to generate module documentation and append it to README.md
	terraform-docs markdown "${module_path}" >>"${readme_file}"

	# Add a separator between the generated documentation and the Terraform graph
	echo -e "\n---\n" >>"${readme_file}"

	# Set header
	echo "# Graph" >>"${readme_file}"
	echo "---" >>"${readme_file}"

	# Run terraform graph and generate a GRAPH.svg
	graph_file="./GRAPH.svg"
	cd ${module_path}
	terraform graph -draw-cycles | dot -Tsvg >>"${graph_file}"

	# deletes init leftovers
	rm -rf .terraform && rm .terraform.lock.hcl
	cd -

	echo '<img src="./GRAPH.svg" alt="" />' >>"${readme_file}"
}

########
# Main #
########
main() {
	module_name=$1
	create_example_markdown "${module_name}"
	create_docs_markdown "${module_name}"
}

main $1
