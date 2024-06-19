
variable "lambda_role_id" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "retention_in_days" {
  type    = number
  default = 1
}

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_iam_policy_document" "allow_lambda_logging" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

// attach policy to out created lambda role
resource "aws_iam_role_policy_attachment" "lambda_logging_policy_attachment" {
  role       = var.lambda_role_id
  policy_arn = aws_iam_policy.function_logging_policy.arn
}

// create a policy to allow writing into logs and create logs stream
resource "aws_iam_policy" "function_logging_policy" {
  name        = "log-${var.lambda_function_name}"
  description = "Policy for lambda cloudwatch logging"
  policy      = data.aws_iam_policy_document.allow_lambda_logging.json
}

// create log group in cloudwatch to gather logs of our lambda function
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.retention_in_days
}
