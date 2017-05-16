#!/usr/bin/env python

# Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Description:
#    A4MCAR Project - High-level Module Dummy Load roughly 25% on a core
#
# Author:
#    M. Ozcelikors <mozcelikors@gmail.com>

import psutil
import time
import string
import numpy

#Timing Related ---start
_DEADLINE = 1.40
_START_TIME = 0
_END_TIME = 0
_EXECUTION_TIME = 0                  
_PREV_SLACK_TIME = 0
_PERIOD = 1.40
#Timing Related ---end

def CreateTimingLog(filename):
	global _START_TIME
	global _DEADLINE
	global _END_TIME
	global _EXECUTION_TIME
	global _PREV_SLACK_TIME
	global _PERIOD
        
	try:
		file_obj = open(str(filename), "w+r")
	except Exception as inst:
		print inst
	_END_TIME = time.time()
	_EXECUTION_TIME = _END_TIME - _START_TIME
	try:
		file_obj.write(str(_PREV_SLACK_TIME)+' '+str(_EXECUTION_TIME)+' '+str(_PERIOD)+' '+str(_DEADLINE))
		file_obj.close()
	except Exception as inst:
		print inst
	
while True:
	#Timing Related ---start
	_START_TIME = time.time()
	_PREV_SLACK_TIME = _START_TIME - _END_TIME
	#Timing Related ---end

	#TASK CONTENT
	a=numpy.random.random([1000,1000])
	b=numpy.random.random([1000,1000])
	c=numpy.mean(a*b)
		
	#Timing Related ---start
	CreateTimingLog("../../logs/timing/dummy_load25_5_timing.inc")
	#Timing Related ---end
        
	#Sleep
	if(_PERIOD>_EXECUTION_TIME):
		time.sleep(_PERIOD - _EXECUTION_TIME)
