# -------------------------------------------------------
# Copyright (c) [2021] Nadege Lemperiere
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

# -------------------------------------------------------
# Configure Config Rules
# -------------------------------------------------------
resource "aws_config_config_rule" "rules" {

	count = length(var.rules)

	name 	= "${var.project}_${var.rules[count.index].name}"
	source {
    	owner             = lookup(var.rules[count.index].source,"owner",null)
    	source_identifier = lookup(var.rules[count.index].source,"source_identifier",null)
  	}

	input_parameters = lookup(var.rules[count.index],"input",null)

	dynamic scope {

		for_each = ((var.rules[count.index].scope != null) ? ["1"] : [])
		content {
			compliance_resource_id 		= lookup(var.rules[count.index].scope,"compliance_resource_id",null)
			compliance_resource_types 	= lookup(var.rules[count.index].scope,"compliance_resource_types",null)
			tag_key 					= lookup(var.rules[count.index].scope,"tag_key",null)
			tag_value 					= lookup(var.rules[count.index].scope,"tag_value",null)
		}
	}

  	depends_on = [
		aws_config_configuration_recorder.config,
		aws_config_delivery_channel.topic_env_sso_config_logging
	]

  	tags = {
		Name           	= "${var.project}.configrule.${var.rules[count.index].name}"
		Environment     = var.environment
		Owner   		= var.email
		Project   		= var.project
		Version 		= var.git_version
		Module  		= var.module
	}
}
