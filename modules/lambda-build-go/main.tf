variable "lambda_build_id" {
  type = string
}

variable "lambda_src" {
  type = string
}

variable "triggers" {
  type = map(string)
  default = {
  }
}

variable "always_update" {
  type    = bool
  default = false
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
  binary_path  = "${path.root}/.bin/${var.lambda_build_id}/bootstrap"
  archive_path = "${path.root}/.bin/${var.lambda_build_id}/bootstrap.zip"
}

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    archive_file = {
      source  = "hashicorp/archive"
      version = ">= 2.2.0"
    }
  }
}

// build the binary for the lambda function in a specified path
resource "terraform_data" "build" {
  provisioner "local-exec" {
    command     = "go build -mod=readonly -ldflags='-s -w' -o ${local.binary_path} ${var.lambda_src}"
    working_dir = path.root
    environment = {
      GOOS        = "linux"
      GOARCH      = "arm64"
      CGO_ENABLED = 0
      GOFLAGS     = "-trimpath"
    }
  }
  triggers_replace = [
    var.always_update ? timestamp() : null,
    jsonencode(var.triggers),
  ]
}

// zip the binary, as we can use only zip files to AWS lambda
data "archive_file" "archive" {
  depends_on = [terraform_data.build]

  type        = "zip"
  source_file = local.binary_path
  output_path = local.archive_path
}
