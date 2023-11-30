# -------------------------------------------------------
# Copyright (c) [2021] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws configuration recorder with all
# the secure components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 30 november 2023
# -------------------------------------------------------

# -------------------------------------------------------
# Contact e-mail for this deployment
# -------------------------------------------------------
variable "email" {
	type 	 = string
	nullable = false
}

# -------------------------------------------------------
# Environment for this deployment (prod, preprod, ...)
# -------------------------------------------------------
variable "environment" {
	type 	 = string
	nullable = false
}

# -------------------------------------------------------
# Topic context for this deployment
# -------------------------------------------------------
variable "project" {
	type     = string
	nullable = false
}
variable "module" {
	type 	 = string
	nullable = false
}

# -------------------------------------------------------
# Solution version
# -------------------------------------------------------
variable "git_version" {
	type     = string
	nullable = false
	default  = "unmanaged"
}

#  -------------------------------------------------------
# Bucket description
# --------------------------------------------------------
variable "bucket" {
	type = object({
		name 	= string
		prefix	= string
	})
	nullable = false
}

#  -------------------------------------------------------
# Cloudwatch role to use for logging
# --------------------------------------------------------
variable "cloudwatch" {
	type = object({
		role	= string
	})
	nullable = false
}

# -------------------------------------------------------
# Config rules
# -------------------------------------------------------
variable "rules" {
	type = list(object({
		name			= string,
		source 			= object({
			owner = string,
			source_identifier = string
		}),
		input			= optional(string),
		scope			= object({
			compliance_resource_id 		= optional(string)
			compliance_resource_types   = optional(list(string))
			tag_key   					= optional(string)
			tag_value   				= optional(string)
		})
	}))
	nullable = false
}