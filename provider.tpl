provider "aws" {
  region = "${region}"
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${account_id}"]

   # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  %{ if assume_role_arn != "" }
  assume_role {
    role_arn = "${assume_role_arn}"
  }
  %{ endif }
}
