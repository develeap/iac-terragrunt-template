module "role" {
    source = "../../path/to/this/module"

    assume_role_policy = ""
    role_name          = "terraform_bot"
    tags               = {}
}
