#!/usr/bin/env python
import psutil
import time
import string
import numpy

#Timing Related ---start
_DEADLINE = 0.50
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
		CreateTimingLog("deadline_logger_burn_cycles_around25_5.inc")
        #Timing Related ---end
        
		#Sleep
        time.sleep(_PERIOD - _EXECUTION_TIME)
