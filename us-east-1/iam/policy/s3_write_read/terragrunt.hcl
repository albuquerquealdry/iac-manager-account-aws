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

terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-policy?version=5.34.0"
}

inputs = {
  name_prefix = "s3_read_write_policy"
  path        = "/"
  description = "s3_read_write_policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": "*"
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object",
            "Resource": "*"
        }
    ]
  })
  tags = local.tags
}
