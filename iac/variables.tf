variable "linode_api_token" {
  sensitive   = true
}

variable "root_user_pw" {
  sensitive   = true
}
variable "git_repo" {}

variable "node_count" {
    description = "The amount of backend Nodes to create."
}