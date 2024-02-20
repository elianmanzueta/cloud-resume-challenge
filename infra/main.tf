# Provider configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      terraform = "Built with Terraform"
      project   = "Cloud Resume Challenge"
    }
  }
}

# Variables
variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

# Resources

# DynamoDB
resource "aws_dynamodb_table" "database" {
  name         = "terraform-test-resume-challenge"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "N"
  }

}

resource "aws_dynamodb_table_item" "views" {
  table_name = aws_dynamodb_table.database.name
  hash_key   = aws_dynamodb_table.database.hash_key

  item = <<ITEM
  {
  "id":{"N": "0"},
  "views":{"N": "0"}
  }
  ITEM
}
##########

# S3 Bucket
resource "aws_s3_bucket" "bucket" {
  bucket        = "elian-cloudresumechallenge"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode(
    {
      "Version" : "2008-10-17",
      "Id" : "PolicyForCloudFrontPrivateContent",
      "Statement" : [
        {
          "Sid" : "AllowCloudFrontServicePrincipal",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "cloudfront.amazonaws.com"
          },
          "Action" : "s3:GetObject",
          "Resource" : "${aws_s3_bucket.bucket.arn}/*",
          "Condition" : {
            "StringEquals" : {
              "AWS:SourceArn" : aws_cloudfront_distribution.cloudfront.arn
            }
          }
        }
      ]
  })

}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
##########

# Lambda
resource "aws_lambda_function" "lambda" {
  function_name = "increment-views"
  filename      = "../lambda/increment-views-lambda-function.zip"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  role = "arn:aws:iam::842766024795:role/service-role/dynamodb-access"
}

resource "aws_lambda_function_url" "function-url" {
  function_name      = aws_lambda_function.lambda.function_name
  authorization_type = "NONE"

  cors {
    allow_origins = ["https://resume.eliandm.com"]
  }

}
##########

# Cloudfront
data "aws_cloudfront_cache_policy" "policy" {
  name = "Managed-CachingOptimized"

}

resource "aws_cloudfront_distribution" "cloudfront" {

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = ["resume.eliandm.com"]

  origin {
    origin_id                = aws_s3_bucket.bucket.bucket_regional_domain_name
    domain_name              = aws_s3_bucket.bucket.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["HEAD", "GET"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = aws_s3_bucket.bucket.bucket_regional_domain_name
    cache_policy_id        = data.aws_cloudfront_cache_policy.policy.id
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = "arn:aws:acm:us-east-1:842766024795:certificate/3168535f-d11e-4150-90b7-0d836161309a"
    ssl_support_method             = "sni-only"

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"

    }
  }

}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-origin-access-control"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  origin_access_control_origin_type = "s3"

}
##########
