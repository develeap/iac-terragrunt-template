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
	infrastructure_commons_filename="infrastructure.hcl"
	account_commons_filename="account.hcl"
	environment_commons_filename="env.hcl"
	region_commons_filename="region.hcl"

	# Create the infrastructure_commons.hcl file - this file will be used to store the common variables for all the accounts, regions, and environments
  mkdir -p infrastructures
	cat <<-HCL > infrastructures/"${infrastructure_commons_filename}"
	locals {}
	HCL

	for account in "${accounts[@]}"; do
		# Create the account_commons.hcl file - this file will be used to store the common variables for all the regions and environments
    mkdir -p infrastructure-live/"${account}"
		cat <<-HCL > infrastructures/"${account}"/"${account_commons_filename}"
		locals {
		  account_id = "${account}"
		}
		HCL

		for environment in "${environments[@]}"; do
			# Create the environment_commons.hcl file - this file will be used to store the common variables for all the regions
      mkdir -p infrastructure-live/"${account}"/"${environment}"/"${environment}"-1
			cat <<-HCL > infrastructures/"${account}"/"${environment}"/"${environment_commons_filename}"
			locals {
			  environment = "${environment}"
			}
			HCL

			for region in "${regions[@]}"; do
        mkdir -p infrastructure-live/"${account}"/"${environment}"/"${environment}"-1/"${region}"
				cat <<-HCL > infrastructures/"${account}"/"${environment}"/"${environment}"-1/"${region}"/"${region_commons_filename}"
				locals {
				  region = "${region}"
				}
				HCL

				# Create directories & commons for each of them using a loop
				for dir in "${subjects[@]}"; do
					mkdir -p infrastructure-live/"${account}"/"${environment}"/"${environment}"-1/"${region}"/"${dir}"
					cat <<-HCL > infrastructures/"${account}"/"${environment}"/"${environment}"-1/"${region}"/"${dir}"/"${dir}"
					locals {
					  field = "${dir}"
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
