# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2021] Technogix.io
# All rights reserved
# -------------------------------------------------------
# Simple deployment for module testing
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 12 november 2021
# -------------------------------------------------------

# -------------------------------------------------------
# Create the s3 bucket
# -------------------------------------------------------
resource "random_string" "random1" {
	length		= 32
	special		= false
	upper 		= false
}
resource "aws_s3_bucket" "bucket" {
	bucket = random_string.random1.result
}
resource "aws_s3_bucket_policy" "bucket" {

	bucket = aws_s3_bucket.bucket.id
  	policy = jsonencode({
    	Version = "2012-10-17"
		Statement =[
			{
				Sid 			= "AllowS3ModificationToRootAndGod"
				Effect			= "Allow"
				Principal		= "*"
				Action 			= "s3:*"
				Resource 		= [ "${aws_s3_bucket.bucket.arn}", "${aws_s3_bucket.bucket.arn}/*"]
       		}
		]
	})
}

# -------------------------------------------------------
# Create the loggroup
# -------------------------------------------------------
resource "random_string" "random2" {
	length		= 32
	special		= false
	upper 		= false
}
resource "aws_cloudwatch_log_group" "group" {
  name =  random_string.random1.result
}

# -----------------------------------------------------------
# Create role to enable writing in the loggroup
# -----------------------------------------------------------
resource "aws_iam_role" "group" {

  	name = "test"
  	assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
   			{
      			Effect 		= "Allow"
      			Principal 	=  { "Service": "config.amazonaws.com" }
    			Action 		= "sts:AssumeRole"
    		}
  		]
	})
}
resource "aws_iam_role_policy" "group" {

  	name = "test"
  	role = aws_iam_role.group.id

  	policy = jsonencode({
  		Version = "2012-10-17",
  		Statement = [
    		{
      			Effect 	= "Allow"
      			Action  = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:DescribeLogGroups",  "logs:DescribeLogStreams"]
      			Resource: "${aws_cloudwatch_log_group.group.arn}:*"
    		},
    		{
      			Effect 	= "Allow"
      			Action = ["logs:PutLogEvents"]
      			Resource = "${aws_cloudwatch_log_group.group.arn}:*"
    		}
  		]
	})
}

# -------------------------------------------------------
# Create subnets using the current module
# -------------------------------------------------------
module "config" {

	source 				= "../../../"
	email 				= "moi.moi@moi.fr"
	project 			= "test"
	environment 		= "test"
	module 				= "test"
	git_version 		= "test"
	bucket 				= {
		name 	= aws_s3_bucket.bucket.id
		prefix 	= "global"
	}
	cloudwatch			=  {
		role 	= aws_iam_role.group.arn
	}
	rules = [{
		name = "eip_attached"
		source = {
			owner = "AWS"
			source_identifier = "EIP_ATTACHED"
		}
		scope = {
			compliance_resource_types = [ "AWS::EC2::EIP" ]
		}
	}]
}

# -------------------------------------------------------
# Terraform configuration
# -------------------------------------------------------
provider "aws" {
	region		= var.region
	access_key 	= var.access_key
	secret_key	= var.secret_key
}

terraform {
	required_version = ">=1.0.8"
	backend "local"	{
		path="terraform.tfstate"
	}
}

# -------------------------------------------------------
# Region for this deployment
# -------------------------------------------------------
variable "region" {
	type    = string
}

# -------------------------------------------------------
# AWS credentials
# -------------------------------------------------------
variable "access_key" {
	type    	= string
	sensitive 	= true
}
variable "secret_key" {
	type    	= string
	sensitive 	= true
}

# -------------------------------------------------------
# Test outputs
# -------------------------------------------------------
output "bucket" {
	value = {
		name	= aws_s3_bucket.bucket.id
		arn 	= aws_s3_bucket.bucket.arn
	}
}

output "loggroup" {
    value = {
        arn     = aws_cloudwatch_log_group.group.arn
        name    = aws_cloudwatch_log_group.group.name
        id      = aws_cloudwatch_log_group.group.id
		role 	= aws_iam_role.group.arn
    }
}

output "config" {
    value = module.config.id
}
