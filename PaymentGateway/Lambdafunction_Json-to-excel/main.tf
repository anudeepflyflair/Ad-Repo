provider "aws" {
  region = var.aws_region
}

data "aws_s3_bucket" "source_bucket" {
  bucket = var.source_bucket_name
}

data "aws_s3_bucket" "target_bucket" {
  bucket = var.target_bucket_name
}

resource "aws_iam_role" "json_to_excel_role" {
  name = "json_to_excel_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "json_to_excel_policy" {
  name        = "json_to_excel_policy"
  description = "IAM policy for Lambda to access S3 buckets"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.source_bucket_name}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.source_bucket_name}/*",
          "arn:aws:s3:::${var.target_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "json_to_excel_policy_attachment" {
  policy_arn = aws_iam_policy.json_to_excel_policy.arn
  role       = aws_iam_role.json_to_excel_role.name
}

resource "aws_lambda_function" "my_lambda" {
  function_name = var.lambda_function_name
 
  s3_bucket = var.lambda_code_bucket  # Your Lambda function code bucket
  s3_key    = var.lambda_function_key  # The key of the Lambda zip file in the bucket
  timeout   = 30  #set timeout
  handler = "lambda_function.lambda_handler"  # Adjust if your handler is different
  runtime = var.lambda_runtime  # Make sure this matches your function's runtime

  role = aws_iam_role.json_to_excel_role.arn

  environment {
    variables = {
      SOURCE_BUCKET = data.aws_s3_bucket.source_bucket.bucket
      TARGET_BUCKET = data.aws_s3_bucket.target_bucket.bucket
      TARGET_KEY    = "booking_data.xlsx"
    }
  }

  layers = [var.lambda_layer_arn]  # Your Layer ARN
}

output "lambda_function_arn" {
  value = aws_lambda_function.my_lambda.arn
}  
