# Locals
locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.terragrunt.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.terragrunt.hcl"))
  common           = read_terragrunt_config(find_in_parent_folders("common.terragrunt.hcl"))
  account          = read_terragrunt_config(find_in_parent_folders("account.terragrunt.hcl"))

  environment = local.environment_vars.locals.environment
  tags        = local.environment_vars.locals.tags
  aws_region  = local.region_vars.locals.aws_region
  project     = local.common.locals.project
  account_id  = local.account.locals.aws_account_id
  owner       = local.common.locals.owner
  
  name_policy = "s3_read_write_policy"
}
include {
  path = "${find_in_parent_folders()}"
}

dependency "boundary_policy" {
    config_path = "../policy/boudary_users_operate"
}

dependency "policy_user" {
    config_path = "../policy/s3_write_read"
}
terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-user?version=5.34.0"
}

inputs = {
  name = "valeska_funk"
  create_iam_user_login_profile = true
  create_iam_access_key         = false
  tags                          = local.tags
  policy_arns                   = [dependency.policy_user.outputs.arn]
  permissions_boundary          =  dependency.boundary_policy.outputs.arn
}
