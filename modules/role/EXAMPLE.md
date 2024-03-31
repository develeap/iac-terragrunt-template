module "role" {
    source = "../../path/to/this/module"

    assume_role_policy    = ""
  description           = ""
  force_detach_policies = false
  inline_policy         = ""
  managed_policy_arns   = []
  max_session_duration  = 3600
  name                  = "terraform_bot"
  path                  = "/"
  permissions_boundary  = ""
  tags                  = {}
}
