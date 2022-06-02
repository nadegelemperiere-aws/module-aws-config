# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2022] Technogix SARL
# All rights reserved
# -------------------------------------------------------
# Keywords to create data for module test
# -------------------------------------------------------
# Nadège LEMPERIERE, @13 november 2021
# Latest revision: 13 november 2021
# -------------------------------------------------------

# System includes
from json import load, dumps

# Robotframework includes
from robot.libraries.BuiltIn import BuiltIn, _Misc
from robot.api import logger as logger
from robot.api.deco import keyword
ROBOT = False

# ip address manipulation
from ipaddress import IPv4Network

@keyword('Load Standard Test Data')
def load_standard_test_data(bucket, loggroup, config, account, region) :

    result = {}
    result['config'] = []

    result['config'].append({})
    result['config'][0]['name'] = 'config'
    result['config'][0]['data'] = {}

    result['config'][0]['data']['roleARN']                       = loggroup['role']
    result['config'][0]['data']['recordingGroup']                = {
        'allSupported' : True
    }
    # result['config'][0]['data']['Status'] = True
    # status takes a while to switch to true

    result['rule'] = []

    result['rule'].append({})
    result['rule'][0]['name'] = 'rule'
    result['rule'][0]['data'] = {}

    result['rule'][0]['data']['Source'] = {}
    result['rule'][0]['data']['Source']['Owner'] = 'AWS'
    result['rule'][0]['data']['Source']['SourceIdentifier'] = 'EIP_ATTACHED'
    result['rule'][0]['data']['ConfigRuleState'] = 'ACTIVE'
    result['rule'][0]['data']['Scope'] = {}
    result['rule'][0]['data']['Scope']['ComplianceResourceTypes'] = ['AWS::EC2::EIP']

    logger.debug(dumps(result))

    return result
