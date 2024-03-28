####################################################################################################
#   Author: Lior Dux @zMynxx
#   Description: A Justfile for managing Sops and age
#   Usage: just --list
#   Taken from: https://github.com/zMynxx/Toolbox/blob/feature/sops-aghe/mozilla-sops/README.md
#   License: MIT
#   Version: 0.1
####################################################################################################
#!/usr/bin/env -S just --justfile
# ^ A shebang isn't required, but allows a justfile to be executed
#   like a script, with `./justfile test`, for example.

set ignore-comments := false
set positional-arguments := true
log := "warn"

#############
## Chooser ##
#############

# Run fuzzy finder selector
default:
    @just --choose

#############
## Install ##
#############

# Install Sops
install-sops:
    @echo "Installing Sops using Homebrew..."
    brew install sops 

# Install Age
install-age:
    @echo "Installing Age using Homebrew..."
    brew install age 

# Install Sops plugin for vscode
install-code-sops:
    @echo "Installing Sops plugin for vscode..."
    code --install-extension signageos.signageos-vscode-sops --install-extension mikestead.dotenv

###############
## Configure ##
###############

# Configure Sops with a KMS key
config-kms:
    @echo "Ensure you have the AWS CLI installed and configured with the right profile!"
    @echo "Configuring Sops with kms..."

    echo 'awsProfile: ${AWS_PROFILE:-default}' >> .sopsrc

    cat <<-YAML > .sops.yaml
    creation_rules:
    - path_regex: .yaml$
    - kms: $(aws kms list-keys --output json | jq -r '.Keys[] | .KeyArn' | fzf)
    YAML

# Run the build command
config-age:
    @echo "Configuring Sops with Age..."
    mkdir -p ~/.sops/age
    age-keygen -o ~/.sops/age/key.txt
    echo 'export SOPS_AGE_KEY_FILE="$HOME/.sops/age/key.txt" >> ~/.zshrc'
    source ~/.zshrc

    echo 'ageKeyFile: ~/.sops/age/key.txt' >> .sopsrc

    cat <<-YAL > .sops.yaml
    creation_rules:
    - path_regex: .yaml$
    - age: $(cat $SOPS_AGE_KEY_FILE | grep -o "public key: .*" | awk '{print $NF}')
    YAML

################
## Encryption ##
################

# Encrypt a file
encrypt *FILE:
    @echo "Encrypting *FILE..."
    sops --encrypt --in-place {{FILE}}

################
## Decryption ##
################

# Encrypt a file
decrypt *FILE:
    @echo "Decrypting *FILE..."
    sops --decrypt --in-place {{FILE}}

#############
# Terraform #
#############

# Create a new Terraform module
create-tf-module *NAME:
    @echo "Creating a new Terraform module..."
    @bash ./scripts/create-module.sh {{NAME}} 

# Create documentation for a Terraform module
create-tf-docs *NAME:
    @echo "Creating documentation for {{NAME}} module..."
    @bash ./scripts/create-docs.sh {{NAME}}

##############
# Terragrunt #
##############

# Build folder structure
build-folder-structure:
    @echo "Building folder structure..."
    bash ./scripts/build-folder-structure.sh

# Create a new Terragrunt module
create-tg-module *NAME:
    @echo "Creating a new Terragrunt module..."
    @bash ./scripts/create-terragrunt-module.sh {{NAME}}
