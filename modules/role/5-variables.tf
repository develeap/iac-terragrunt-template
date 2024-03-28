variable "assume_role_policy" {
  type        = string
  description = "provide a trust policy for this role."
}

variable "name" {
  type        = string
  description = "provide a name for created role."
  default     = "terraform_bot"
}

variable "tags" {
  type        = map(string)
  description = "provide your own tags."
  default     = {}
}

variable "managed_policy_arns" {
  type        = list(string)
  description = "provide a list of managed policy arns."
  default     = []
}

variable "description" {
  type        = string
  description = "provide your description."
  default     = ""
}

variable "force_detach_policies" {
  type        = bool
  description = "Whether to force detaching any policies the role has before destroying it"
  default     = false
}

variable "inline_policy" {
  type        = any
  description = "provide an inline policy for this role."
  default     = null
}

variable "max_session_duration" {
  type        = number
  description = "Limit this role's seesion duration (secounds)."
  default     = 3600
}

# variable "name_prefix" {
#     type = string
#     description = "provide your own prefix for this role name."
#     default = ""
# } 

variable "path" {
  type        = string
  description = "Path to the role"
  default     = "/"
}

variable "permissions_boundary" {
  type        = string
  description = "ARN of the policy that is used to set the permissions boundary for the role."
  default     = ""
}