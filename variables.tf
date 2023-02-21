# Input variable definitions
variable "aws_region" {
  description = "AWS region for all resources."
  type    = string
  default = "eu-west-2"
}

########## Lambda Vars ##########
variable "lambda_function_name" {
  description = "Lambda Function Name"
  type        = string
  default = "my-lambda-function"
}

# variable "s3_bucket_id" {
#   description = "Lambda Functions S3 Bucket ID"
#   type        = string
# }

# variable "s3_bucket_key" {
#   description = "Lambda Functions S3 Bucket Key"
#   type        = string
# }

variable "lambda_handler" {
  description = "Lambda Handler(Default: index.handler)"
  type        = string
  default     = "index.handler"
}

variable "lambda_runtime" {
  description = "Lambda Runtime"
  type        = string
  default = "python3.8"
}
##################################

########## API Gateway  ##########
variable "api_name" {
  description = "Name of Api Gateway"
  type        = string
  default = "my-lambda-api"
}

variable "api_deployment_stage_name" {
  description = "Deployment stage name"
  type        = string
  default = "my-staging-deployment"

}
##################################

variable "env_app_url" {
  description = "LambdaAppURL"
  type = string
  default = "https://testapi.ro"
}
