# [Docs](https://terragrunt.gruntwork.io/docs)
## Use different sources
```hcl
terraform {
	source = "tfr:///aws-ia/eks-blueprints-addon/aws?version=1.1.0"
	source = "[git:///aws-ia/eks-blueprints-addon/aws?version=1.1.0](git::git@github.com:acme/infrastructure-modules.git//networking/vpc?ref=v0.0.1)"
	source = "${get_path_to_repo_root()}//modules/iam"
}
```

## Hooks

```hcl
terraform {
	
  source = "."

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
}
```

## Declare a provider && remote state once

```hcl
locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load project-level variables
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.account_id
  region       = local.region_vars.locals.region
  env          = local.environment_vars.locals.env
  project      = local.project_vars.locals.project

  # TAGS
  tg_tags = tomap({ Terragrunt = "True" })
  computed_tags = tomap({
    # LastModifiedTime = "${timestamp()}" // uncomment only after delivery
    # LastModifiedBy   = "${get_aws_caller_identity_arn()}"
  })
  account_tags = tomap({
    AccountName = "${local.account_name}",
    AccountId   = "${local.account_id}"
  })
  region_tags = tomap({
    Region = "${local.region}"
  })
  env_tags = tomap({
    Environment = "${local.env}"
  })
  project_tags = tomap({
    Project = "${local.project}"
  })
  tags_all = jsonencode(merge(
    local.tg_tags,
    local.computed_tags,
    local.account_tags,
    local.region_tags,
    local.env_tags,
    local.project_tags
  ))
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<-EOPROVIDER
  provider "aws" {
	  # Set the `profile` variable to have a value of the `AWS_PROFILE` env var 
	  # Default value is "dev-profile" if that env var is not set
	profile = get_env("SMIP", "AWS_PROFILE")
    region  = "${local.region}"

    # Only these AWS Account IDs may be operated on by this template
    allowed_account_ids = ["${local.account_id}"]

    assume_role {
      role_arn = "arn:aws:iam::${local.account_id}:role/prod.terraform_bot.role"
      session_name = "prod.terraform_bot.role"
    }

    default_tags {
      # Use heredoc syntax to render the json to avoid quoting complications.
      tags = jsondecode(
      <<-INNEREOF
      ${local.tags_all}
      INNEREOF
      )
    }
  }
  EOPROVIDER
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = "${local.env}.terraform-remote-state.s3"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.region}"
    profile        = "SMIP"
    encrypt        = true
    dynamodb_table = "${local.env}.terraform_remote_state_lock.dynamodb"
    s3_bucket_tags = merge(
      local.tg_tags,
      local.computed_tags,
      local.account_tags,
      local.region_tags,
      local.env_tags
    )
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
  local.project_vars.locals
)
```

```hcl
## Link with the root `terragrunt.hcl` file where we defined provider.
include "provider" {
	path = find_in_parent_folders("terragrunt.hcl")
}
```

### When additional providers needed for specific modules

```hcl
generate "helm_provider" {
  path      = "helm_provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<-EOF
  data "aws_eks_cluster" "eks" {
    name = "${dependency.eks.outputs.cluster_name}"
  }

  data "aws_eks_cluster_auth" "eks" {
    name = "${dependency.eks.outputs.cluster_name}"
  }

  provider "helm" {
    kubernetes {
      host                   = data.aws_eks_cluster.eks.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
      token                  = data.aws_eks_cluster_auth.eks.token
    }
  }
  EOF
)
```
### Local plugins directory

```
├── environments  
├── modules  
├── **terraform_aws_plugins**  
│ └── **plugins**  
│   ├── darwin_amd64  
│   │ ├── terraform-provider-aws_v2.46.0_x4  
│   │ ├── terraform-provider-local_v1.3.0_x4  
│   │ ├── terraform-provider-null_v2.1.2_x4  
│   │ ├── terraform-provider-random_v2.2.0_x4  
│   │ └── terraform-provider-template_v2.1.2_x4  
│   └── linux_amd64  
│   ├── terraform-provider-aws_v2.46.0_x4  
│   ├── terraform-provider-local_v1.3.0_x4  
│   ├── terraform-provider-null_v2.1.2_x4  
│   ├── terraform-provider-random_v2.2.0_x4  
│   └── terraform-provider-template_v2.1.2_x4
```

```hcl
terraform {
    extra_arguments "init_args" {
    commands  = ["init"]
    arguments = ["-get-plugins=false", "-plugin-dir=${get_terragrunt_dir()}/${find_in_parent_folders("terraform_aws_plugins")}/plugins/${get_env("terraform_provider_platform", "darwin_amd64")}"]
  }
}
```

### Using VPC Endpoints

```hcl
provider "aws" {
  region = "ap-southeast-1"
  endpoints {
    sts = "https://sts.ap-southeast-1.amazonaws.com"
  }
}
```

## Clean all Cache

```bash
find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
```

### Debug

```bash
terragrunt apply --terragrunt-log-level debug --terragrunt-debug
```


## Rename / Move Modules

> In the following example we will rename a module named api to api-analytics.

1. Create a backup of the current state file: `terragrunt state pull > /var/app/staging-api-backup.tfstate`
2. Move/Rename the folder: `mv api api-analytics`
3. Init current folder to create the s3 path desired: `cd api-analytics; terragrunt init`
4. Push the backup state file: `terragrunt state push /var/app/staging-api-backup.tfstate`
5. Plan to see that nothing had changed: `terragrunt plan`

## Set the lock timeout
```hcl
terrafrom {

  # For any terraform commands that use locking, make sure to configure a lock timeout of 20 minutes.
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=20m"]
  }
}
```

## Protect sensitive resources
```hcl
prevent_destroy = true
```

## Set needed versions
```hcl
terraform_version_constraint = ">= 0.11"
terragrunt_version_constraint = ">= 0.23"
```

## Encryption using SOPS
[Sops](https://github.com/getsops/sops)

1. Store your secrets in a file:
```json
{
   "passoword": "super-secret-password"
}
```

2. Set your encryption key configurations:
```yaml
# creation rules are evaluated sequentially, the first match wins  
creation_rules:  
     # upon creation of a file that matches the pattern *.dev.yaml,  
     #KMS set A is used  
     - kms: "arn:aws:kms:**<region>**:**<accountNo>**:key/**<KMS-ID>**"
```

3.  Encrypt your secrets file using sops:  `sops --encrypt secrets.json`
4. Read secrets using `sops_decrypt_file`:

```hcl
locals {
  secret_vars = try(jsondecode(sops_decrypt_file(find_in_parent_folders("secrets.json"))), {})
}

inputs = merge(
  local.secret_vars, # This will be {}, if secrets.json fails to load / empty
  {
    # additional inputs
  }
)
```
