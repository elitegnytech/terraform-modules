variable "rest_api_id" {
  type = string
}

variable "root_resource_id" {
  type = string
}

variable "path" {
  type = string
}

variable "stage_name" {
  type = string
}

variable "stage_description" {
  type = string
}

variable "lambda_invoke_arn" {
  type = string
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


resource "aws_api_gateway_method" "this" {
  rest_api_id   = var.rest_api_id
  resource_id   = var.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = var.rest_api_id
  resource_id             = var.root_resource_id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_integration_response" "this" {
  rest_api_id = var.rest_api_id
  resource_id = var.root_resource_id
  http_method = aws_api_gateway_method.this.http_method
  status_code = aws_api_gateway_method_response.this.status_code

  depends_on = [
    aws_api_gateway_method.this,
    aws_api_gateway_integration.this
  ]

  # response_parameters = {
  #   "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
  #   "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
  #   "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  # }
}

resource "aws_api_gateway_method_response" "this" {
  rest_api_id = var.rest_api_id
  resource_id = var.root_resource_id
  http_method = aws_api_gateway_method.this.http_method
  status_code = 200
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.this,
    aws_api_gateway_integration_response.this
  ]

  rest_api_id       = var.rest_api_id
  stage_name        = var.stage_name
  stage_description = var.stage_description
  description = "Created by terraform - ${aws_api_gateway_integration.this.id}"
}