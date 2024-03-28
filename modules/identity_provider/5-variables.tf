variable "tags" {
  type        = map(string)
  description = "provide your own tags."
  default     = {}
}

variable "github_url" {
  type        = string
  description = "provide github domain for thumbprint capture (no protocol prefix). defaults to 'token.actions.githubusercontent.com'."
  default     = "token.actions.githubusercontent.com"
}