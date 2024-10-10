aws_region           = "ca-central-1"  # Change to your desired region
source_bucket_name   = "json-source-code-bucket"
target_bucket_name   = "xl-output-bucket"
lambda_code_bucket   = "jsontoexcellambdaexecution"
lambda_function_name = "Json-to-excel-lambdafunction"
lambda_function_key  = "lambda_funtion.zip"  # Adjust if your zip file is in a subdirectory
lambda_runtime       = "python3.9"  # Adjust if needed
lambda_layer_arn     = "arn:aws:lambda:ca-central-1:336392948345:layer:AWSSDKPandas-Python39:27"  # Replace with your Layer ARN

