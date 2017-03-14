#!/usr/bin/env python
import psutil
import time
import string
ctr1 = 0
ctr2 = 0
ctr3 = 0
ctr4 = 0
mod_ctr = 0
record1=0
record2=0
record3=0
record4=0
a=[0,0,0,0]
b=[0,0,0,0]
c=[0,0,0,0]
d=[0,0,0,0]


#Timing Related ---start
_DEADLINE = 0.0062
_START_TIME = 0
_END_TIME = 0
_EXECUTION_TIME = 0.0050                  
_PREV_SLACK_TIME = 0
_PERIOD = 3
ctrl = 0
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
        CreateTimingLog("deadline_logger_record_core_usage_rpi.inc")
        #Timing Related --end

        if (ctrl == 1):
                #Sleep
                d = psutil.cpu_percent(interval=(_PERIOD - _EXECUTION_TIME), percpu=True)

        #Timing Related --start
        _START_TIME = time.time()
        _PREV_SLACK_TIME = _START_TIME - _END_TIME
        #Timing Related --end

        #TASK CONTENT
        ctrl = 1
        ctr1 = ctr1 + 1
	newtext = str(a[0])+","+str(a[1])+","+str(a[2])+","+str(a[3])+","+str(ctr1)+","+str(b[0])+","+str(b[1])+","+str(b[2])+","+str(b[3])+","+str(ctr1)+","+str(c[0])+","+str(c[1])+","+str(c[2])+","+str(c[3])+","+str(ctr1)+","+str(d[0])+","+str(d[1])+","+str(d[2])+","+str(d[3])+","+str(ctr1)
	text_file = open("core_usage_rpi.inc","w+r")
	text_file.write(newtext)
	text_file.close()
        
