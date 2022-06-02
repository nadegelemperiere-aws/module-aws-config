# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2021] Technogix.io
# All rights reserved
# -------------------------------------------------------
# Robotframework test suite for module
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 12 november 2021
# -------------------------------------------------------


*** Settings ***
Documentation   A test case to check config creation using module
Library         technogix_iac_keywords.terraform
Library         technogix_iac_keywords.keepass
Library         technogix_iac_keywords.config
Library         technogix_iac_keywords.s3
Library         ../keywords/data.py
Library         OperatingSystem

*** Variables ***
${KEEPASS_DATABASE}                 ${vault_database}
${KEEPASS_KEY_ENV}                  ${vault_key_env}
${KEEPASS_PRINCIPAL_KEY_ENTRY}      /engineering-environment/aws/aws-principal-access-key
${KEEPASS_ACCOUNT_ENTRY}            /engineering-environment/aws/aws-account
${REGION}                           us-east-1

*** Test Cases ***
Prepare environment
    [Documentation]         Retrieve principal credential from database and initialize python tests keywords
    ${vault_key}            Get Environment Variable          ${KEEPASS_KEY_ENV}
    ${principal_access}     Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${vault_key}  ${KEEPASS_PRINCIPAL_KEY_ENTRY}      username
    ${principal_secret}     Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${vault_key}  ${KEEPASS_PRINCIPAL_KEY_ENTRY}      password
    ${ACCOUNT}              Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${vault_key}  ${KEEPASS_ACCOUNT_ENTRY}            password
    Initialize Terraform    ${REGION}   ${principal_access}   ${principal_secret}
    Initialize Config       None        ${principal_access}   ${principal_secret}    ${REGION}
    Initialize S3           None        ${principal_access}   ${principal_secret}    ${REGION}
    Set Global Variable     ${ACCOUNT}

Create Config
    [Documentation]         Create Config And Check That The AWS Infrastructure Match Specifications
    Launch Terraform Deployment                 ${CURDIR}/../data/standard
    ${states}   Load Terraform States           ${CURDIR}/../data/standard
    ${specs}    Load Standard Test Data         ${states['test']['outputs']['bucket']['value']}    ${states['test']['outputs']['loggroup']['value']}   ${states['test']['outputs']['config']['value']}  ${ACCOUNT}     ${REGION}
    Recorders Shall Exist And Match             ${specs['config']}
    Rules Shall Exist And Match                 ${specs['rule']}
    Empty S3 Bucket                             ${states['test']['outputs']['bucket']['value']['name']}
    [Teardown]  Destroy Terraform Deployment    ${CURDIR}/../data/standard
