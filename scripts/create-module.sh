###########################################################################################
# Author: Lior Dux @zMynxx
# Description: This script generates a Terraform module structure with the required files. 
# Usage: ./create-module.sh <module_name> 
# Example: ./create-module.sh my-module
# Dependencies: None
# License: MIT
# Version: 1.0
###########################################################################################
#!/bin/bash
mkmodule() {
  if [ -z "$1" ]; then
    echo "Module name not provided."
    return 1
  fi
  
  modules_dir="modules"
  module_name=$1
  module_path="$modules_dir"/"$module_name"
  mkdir -p $module_path || return 1
  
  # Create a versions template for this module
  cat <<TF >"$module_path/0-versions.tf"
terraform {
  required_version = ">= $(terraform --version | head -1 | awk '{print $2}' | sed 's/v//' | sed 's/+.*//')"
}
TF

  # Create a main.tf file for this module
  cat <<TF >"$module_path/1-main.tf"
resource "example" "example"{
  
}
TF

  # Create a outputs.tf file for this module
  cat <<TF >"$module_path/2-outputs.tf"
output "$module_name" {
  value = module.*
}
TF

  # Create a locals.tf file for this module
  cat <<TF >"$module_path/3-locals.tf"  
locals {

}
TF

  # Create a data_sources.tf file for this module
  cat <<TF >"$module_path/4-data_sources.tf"
data "example" {

}
TF

  # Create a variables.tf file for this module
  cat <<TF >"$module_path/5-variables.tf"
variable "example" {
  type = string
}
TF
}

mkmodule $1
