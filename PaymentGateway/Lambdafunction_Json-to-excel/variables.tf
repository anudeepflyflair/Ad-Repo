variable "aws_region" {
  description = "The AWS region to deploy to."
  type        = string
}

variable "source_bucket_name" {
  description = "The source S3 bucket name."
  type        = string
}

variable "target_bucket_name" {
  description = "The target S3 bucket name."
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function."
  type        = string
}

variable "lambda_function_key" {
  description = "The S3 key for the Lambda function code."
  type        = string
}

variable "lambda_runtime" {
  description = "The runtime for the Lambda function."
  type        = string
}

variable "lambda_layer_arn" {
  description = "The ARN of the Lambda Layer."
  type        = string
}

variable "lambda_code_bucket" {
  description = "The name of the S3 bucket where Lambda function code is stored"
  type        = string
}


