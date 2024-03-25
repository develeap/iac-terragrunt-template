#!/bin/bash set-ex
###########################################################################################
# Author: Lior Dux @zMynxx
# Description: This script generates a Terragrunt best practice folder structure with common files at it's level including inheritence.
# Usage: ./build-folder-structure.sh
# Example: ./build-folder-structure.sh
# Dependencies: None
# License: MIT
# Version: 1.0
###########################################################################################

###########
# Globals #
###########
accounts=('82281136')
regions=('us-east-1' 'us-west-1')
environments=('prod' 'stage' 'dev')
subjects=('storage' 'network' 'secrets' 'compute' 'databases')

#############
# Functions #
#############

# /**
# * @brief This function generates a Terragrunt best practice folder structure with common files at it's level including inheritence.
# * @param - None
# * @return - None
# */
create_structure(){
	mkdir -p modules
	commons_suffix="_commons.hcl"
	infrastructure_commons_filename="infrastructure${commons_suffix}"
	account_commons_filename="account${commons_suffix}"
	environment_commons_filename="environment${commons_suffix}"
	region_commons_filename="region${commons_suffix}"

	# Create the infrastructure_commons.hcl file - this file will be used to store the common variables for all the accounts, regions, and environments
  mkdir -p infrastructures
	cat <<-HCL > infrastructures/"${infrastructure_commons_filename}"
	locals {}
	HCL

	for account in "${accounts[@]}"; do
		# Create the account_commons.hcl file - this file will be used to store the common variables for all the regions and environments
    mkdir -p infrastructures/"${account}"
		cat <<-HCL > infrastructures/"${account}"/"${account_commons_filename}"
		locals {
		  infrastructures_vars = try(read_terragrunt_config(find_in_parent_folders("${infrastructure_commons_filename}")), {})
		  account_id = "${account}"
		}
		HCL

		for environment in "${environments[@]}"; do
			# Create the environment_commons.hcl file - this file will be used to store the common variables for all the regions
      mkdir -p infrastructures/"${account}"/"${environment}"/"${environment}"-1
			cat <<-HCL > infrastructures/"${account}"/"${environment}"/"${environment_commons_filename}"
			locals {
			  account_vars = try(read_terragrunt_config(find_in_parent_folders("${account_commons_filename}")), {})
			  env = "${environment}"
			}
			HCL

			for region in "${regions[@]}"; do
        mkdir -p infrastructures/"${account}"/"${environment}"/"${environment}"-1/"${region}"
				cat <<-HCL > infrastructures/"${account}"/"${environment}"/"${environment}"-1/"${region}"/"${region_commons_filename}"
				locals {
				  environment_vars = try(read_terragrunt_config(find_in_parent_folders("${environment_commons_filename}")), {})
				  region = "${region}"
				}
				HCL

				# Create directories & commons for each of them using a loop
				for dir in "${subjects[@]}"; do
					mkdir -p infrastructures/"${account}"/"${environment}"/"${environment}"-1/"${region}"/"${dir}"
					cat <<-HCL > infrastructures/"${account}"/"${environment}"/"${environment}"-1/"${region}"/"${dir}"/"${dir}${commons_suffix}"
					locals {
					  region_vars = try(read_terragrunt_config(find_in_parent_folders("${region_commons_filename}")), {})
					}
					HCL
				done
			done
		done
	done
}

########
#	Main #
########
main() {
	create_structure
}

main
