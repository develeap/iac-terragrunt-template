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
	for account in "${accounts[@]}"; do
		for region in "${regions[@]}"; do
			for environment in "${environments[@]}"; do
				# Create directories using a loop
				for dir in "storage" "network" "secrets" "compute" "databases"; do mkdir -p infrastructures/"${account}"/"${environment}"/"${environment}"-1/"${region}"/"${dir}"; done

				# Create the infrastructure_commons.hcl file - this file will be used to store the common variables for all the accounts, regions, and environments
				cat <<-HCL > infrastructures/infrastructure_commons.hcl
				locals {}
				HCL

				# Create the account_commons.hcl file - this file will be used to store the common variables for all the regions and environments
				cat <<-HCL > infrastructures/"${account}"/account_commons.hcl
				locals {
					infrastructures_vars = try(read_terragrunt_config(find_in_parent_folders("infrastructure_commons.hcl")), {})
					account_id = \""${account}"\"
				}
				HCL

				cat <<-HCL > infrastructures/"${account}"/"${environment}"/environment_commons.hcl
				locals {
					account_vars = try(read_terragrunt_config(find_in_parent_folders("account_commons.hcl")), {})
					env = \""${environment}"\"
				}
				HCL
				cat <<-HCL > infrastructures/$account/"${environment}"/"${environment}"-1/"${region}"/region_commons.hcl
				locals {
					environment_vars = try(read_terragrunt_config(find_in_parent_folders("environment_commons.hcl")), {})
					region = \""${region}"\"
				}
				HCL

				cat <<-HCL > infrastructures/"${account}"/"${environment}"/"${environment}"-1/"${region}"/storage/storage_commons.hcl
				locals {
					region_vars = try(read_terragrunt_config(find_in_parent_folders("region_commons.hcl")), {})
				}
				HCL

				cat <<-HCL > infrastructures/"${account}"/"${environment}"/"${environment}"-1/"${region}"/network/network_commons.hcl
				locals {
					region_vars = try(read_terragrunt_config(find_in_parent_folders("region_commons.hcl")), {})
				}
				HCL

				cat <<-HCL > infrastructures/"${account}"/"${environment}"/"${environment}"-1/"${region}"/secrets/secrets_commons.hcl
				locals {
					region_vars = try(read_terragrunt_config(find_in_parent_folders("region_commons.hcl")), {})
				}
				HCL

				cat <<-HCL > infrastructures/"${account}"/"${environment}"/"${environment}"-1/"${region}"/compute/compute_commons.hcl
				locals {
					region_vars = try(read_terragrunt_config(find_in_parent_folders("region_commons.hcl")), {})
				}
				HCL

				cat <<-HCL > infrastructures/"${account}"/"${environment}"/"${environment}"-1/"${region}"/databases/databases_commons.hcl
				locals {
					region_vars = try(read_terragrunt_config(find_in_parent_folders("region_commons.hcl")), {})
				}
				HCL
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