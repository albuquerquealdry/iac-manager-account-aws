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
  
  name_policy = "ayo-boundary-policy-operate"
}
include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-policy?version=5.34.0"
}

inputs = {
  name_prefix = "boundary-users-operate"
  path        = "/"
  description = "boundary-users-operate"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "IAMAccess"
        Effect = "Allow"
        Action = "iam:*"
        Resource = "*"
      },
      {
        Sid     = "DenyPermBoundaryIAMPolicyAlteration"
        Effect  = "Deny"
        Action  = [
          "iam:DeletePolicy",
          "iam:DeletePolicyVersion",
          "iam:CreatePolicyVersion",
          "iam:SetDefaultPolicyVersion"
        ]
        Resource = [
          "arn:aws:iam::${local.account_id}:policy/${local.name_policy}-PermissionsBoundary"
        ]
      },
      {
        Sid     = "DenyRemovalOfPermBoundaryFromAnyUserOrRole"
        Effect  = "Deny"
        Action  = [
          "iam:DeleteUserPermissionsBoundary",
          "iam:DeleteRolePermissionsBoundary"
        ]
        Resource = [
          "arn:aws:iam::${local.account_id}:user/*",
          "arn:aws:iam::${local.account_id}:role/*"
        ]
        Condition = {
          StringEquals = {
            "iam:PermissionsBoundary" = "arn:aws:iam::${local.account_id}:policy/${local.name_policy}-PermissionsBoundary"
          }
        }
      },
      {
        Sid     = "DenyAccessIfRequiredPermBoundaryIsNotBeingApplied"
        Effect  = "Deny"
        Action  = [
          "iam:PutUserPermissionsBoundary",
          "iam:PutRolePermissionsBoundary"
        ]
        Resource = [
          "arn:aws:iam::${local.account_id}:user/*",
          "arn:aws:iam::${local.account_id}:role/*"
        ]
        Condition = {
          StringNotEquals = {
            "iam:PermissionsBoundary" = "arn:aws:iam::${local.account_id}:policy/${local.name_policy}-PermissionsBoundary"
          }
        }
      },
      {
        Sid     = "DenyUserAndRoleCreationWithOutPermBoundary"
        Effect  = "Deny"
        Action  = [
          "iam:CreateUser",
          "iam:CreateRole"
        ]
        Resource = [
          "arn:aws:iam::${local.account_id}:user/*",
          "arn:aws:iam::${local.account_id}:role/*"
        ]
        Condition = {
          StringNotEquals = {
            "iam:PermissionsBoundary" = "arn:aws:iam::${local.account_id}:policy/${local.name_policy}-PermissionsBoundary"
          }
        }
      }
    ]
  })
  tags = local.tags
}
