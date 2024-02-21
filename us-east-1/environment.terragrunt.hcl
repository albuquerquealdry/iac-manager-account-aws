locals {
    common = read_terragrunt_config(find_in_parent_folders("common.terragrunt.hcl"))
    account = read_terragrunt_config("account.terragrunt.hcl")
    region = read_terragrunt_config("region.terragrunt.hcl")

    # Configure environment
    environment = "NonProd"
    aws_account_id = local.account.locals.aws_account_id
    aws_region = local.region.locals.aws_region

    tags = {
        Client      = "AYO"
        Product     = "Development"
        Team        = "DevOps"
        Stack       = "NonProd"
        Repository  = "ayo"
        Terraform   = "true" 
    }
}