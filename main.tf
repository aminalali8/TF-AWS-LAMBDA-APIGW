provider "aws" {
  region = var.aws_region
}

############ Remove bunny ###################
# archive lambda function
data "archive_file" "lambda_function_zip" {
  type = "zip"
  source_file = "${path.module}/functions/index.py"
#   source_dir  = "${path.module}/functions"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_s3_bucket" "demo_books_lambda_bucket" {
  bucket = "demo-books-lambdas-${var.environment_unique}"

  tags = {
    Name        = "Bunnyshell-Demo"
    Environment = "Dev"
  }
}
# # upload to s3
resource "aws_s3_object" "lambda_function_zip" {
  bucket = aws_s3_bucket.demo_books_lambda_bucket.id

  key    = "lambda_function.zip"
  source = data.archive_file.lambda_function_zip.output_path

  etag = filemd5(data.archive_file.lambda_function_zip.output_path)
}
################--------------###############

# create lambda from s3
resource "aws_lambda_function" "myLambda" {
  function_name = "${var.lambda_function_name}-${var.environment_unique}"
#   filename = "lambda-function.zip"
  s3_bucket = aws_s3_bucket.demo_books_lambda_bucket.id
#   s3_bucket = var.s3_bucket_id
  s3_key    = aws_s3_object.lambda_function_zip.key
#   s3_key = var.s3_bucket_key
  # handler   = "lambdare.handler"
  handler = var.lambda_handler
  # runtime   = "nodejs14.x"
  runtime = var.lambda_runtime
  role    = aws_iam_role.lambda_role.arn
  source_code_hash = data.archive_file.lambda_function_zip.output_base64sha256

  environment {
    variables = {
      APP_URL = var.env_app_url,
      VERSION = 2
    }
  }
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_role" {
  name = "role_lambda-${var.environment_unique}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_api_gateway_rest_api" "apiLambda" {
  # name = "myApi"
  name = "${var.api_name}-${var.environment_unique}"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxyMethod" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_method.proxyMethod.resource_id
  http_method = aws_api_gateway_method.proxyMethod.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.myLambda.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
  resource_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.myLambda.invoke_arn
}

resource "aws_api_gateway_deployment" "apideploy" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  # stage_name  = "test"
  stage_name = "${var.api_deployment_stage_name}-${var.environment_unique}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.myLambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/*/*"
}