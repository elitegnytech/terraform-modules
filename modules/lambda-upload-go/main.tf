variable "lambda_src" {
  type = string
}

output "output_base64sha256" {
  depends_on = [data.archive_file.archive]
  value      = data.archive_file.archive.output_base64sha256
}

output "output_path" {
  depends_on = [data.archive_file.archive]
  value      = data.archive_file.archive.output_path
}

locals {
  binary_path  = "${var.lambda_src}/bootstrap"
  archive_path = "${var.lambda_src}/bootstrap.zip"
}

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.3.0"
    }
  }
}


// zip the binary, as we can use only zip files to AWS lambda
data "archive_file" "archive" {
  type        = "zip"
  source_file = local.binary_path
  output_path = local.archive_path
  lifecycle {
    precondition {
      condition = fileexists(local.binary_path)
      error_message = "The binary file ${local.binary_path} doesn't exist!"
    }
  }
}
