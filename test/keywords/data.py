# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2021] Technogix.io
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

    logger.debug(dumps(result))

    return result
