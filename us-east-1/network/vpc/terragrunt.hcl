locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.terragrunt.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.terragrunt.hcl"))
  common           = read_terragrunt_config(find_in_parent_folders("common.terragrunt.hcl"))
  account          = read_terragrunt_config(find_in_parent_folders("account.terragrunt.hcl"))

  # Extract out common variables for reuse
  environment = local.environment_vars.locals.environment
  tags        = local.environment_vars.locals.tags
  aws_region  = local.region_vars.locals.aws_region
  project     = local.common.locals.project
  account_id  = local.account.locals.aws_account_id
  owner       = local.common.locals.owner

  cluster_name       = "cyber-${lower(local.environment)}"
  cidr_block         = "10.1.0.0/16"
  name               = "Cyber (${upper(local.environment)})"
  single_nat_gateway = true
}

include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "git::https://github.com/albuquerquealdry/terraform-terragrunt-aws.git//terraform-modules/aws/network/vpc"
}

inputs = {

  name               = local.name
  cdr_block_vpc      = local.cidr_block
  enable_nat_gateway = false
  enable_vpn_gateway = false
  azs                = ["${local.aws_region}a","${local.aws_region}b"]
  public_subnets     = ["10.1.1.0/24"]
  private_subnets    = ["10.1.2.0/24"]
  
  tags               = local.tags
}
 