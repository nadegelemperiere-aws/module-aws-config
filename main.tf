# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2021] Technogix.io
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws configuration recorder with all
# the secure components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 12 november 2021
# -------------------------------------------------------

# -------------------------------------------------------
# Create configuration recorder
# -------------------------------------------------------
resource "aws_config_configuration_recorder" "config" {

  	name     = "${var.project}-config-recorder"
	role_arn = var.cloudwatch.role

	recording_group {
		all_supported = true
		include_global_resource_types = true
	}
}

# -------------------------------------------------------
# Configure Config to log console activities in s3
# -------------------------------------------------------
resource "aws_config_delivery_channel" "topic_env_sso_config_logging" {

  	name           		= "${var.project}-config-events"
  	s3_bucket_name      = var.bucket.name
	s3_key_prefix		= var.bucket.prefix
	depends_on			= [aws_config_configuration_recorder.config]
}
