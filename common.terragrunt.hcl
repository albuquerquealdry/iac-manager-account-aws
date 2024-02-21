# Set common variables for the project. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.

locals {
    prefix  = "iac"
    project = "iac"
    bu      = "ayo"
    owner   = "infraestrutura"
}
