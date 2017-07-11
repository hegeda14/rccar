#!/usr/bin/python

# Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Description:
#    A4MCAR Project - High-level Module Core Recording Process
#
# Author:
#    M. Ozcelikors <mozcelikors@gmail.com>

import psutil
import time
import string

# Global variables
counter = 0
ctrl = 0

# Variables to hold the core utilization values at different instances
a=[0,0,0,0]
b=[0,0,0,0]
c=[0,0,0,0]
d=[0,0,0,0]

#Timing Related ---start
_DEADLINE = 3
_START_TIME = 0
_END_TIME = 0
_EXECUTION_TIME = 0.0050                  
_PREV_SLACK_TIME = 0
_PERIOD = 3
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
	#TASK CONTENT+Sleep
	a=b
	b=c
	c=d

	#Timing Related --start
	CreateTimingLog("../../logs/timing/core_recorder_timing.inc")
	#Timing Related --end

	if (ctrl == 1 and (_PERIOD>_EXECUTION_TIME)):
		#Sleep
		d = psutil.cpu_percent(interval=(_PERIOD - _EXECUTION_TIME), percpu=True)

	#Timing Related --start
	_START_TIME = time.time()
	_PREV_SLACK_TIME = _START_TIME - _END_TIME
	#Timing Related --end

	#TASK CONTENT
	ctrl = 1
	counter = counter + 1
	newtext = str(a[0])+","+str(a[1])+","+str(a[2])+","+str(a[3])+","+str(counter)+","+str(b[0])+","+str(b[1])+","+str(b[2])+","+str(b[3])+","+str(counter)+","+str(c[0])+","+str(c[1])+","+str(c[2])+","+str(c[3])+","+str(counter)+","+str(d[0])+","+str(d[1])+","+str(d[2])+","+str(d[3])+","+str(counter)
	text_file = open("/var/www/html/core_usage_rpi.inc","w+r")
	text_file.write(newtext)
	text_file.close()
        
