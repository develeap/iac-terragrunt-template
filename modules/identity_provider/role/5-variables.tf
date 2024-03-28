variable "assume_role_policy" {
  type        = string
  description = "provide a trust policy for this role."
}

variable "role_name" {
  type        = string
  description = "provide a name for created role."
  default     = "terraform_bot"
}

variable "tags" {
  type        = map(string)
  description = "provide your own tags."
  default     = {}
}