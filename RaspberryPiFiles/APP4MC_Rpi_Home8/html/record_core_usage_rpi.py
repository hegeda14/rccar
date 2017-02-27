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

DEADLINE = 0.0055 #0.0062
current_time = 0
previous_time = 0

while True:
        
        #---
	a=b
	b=c
	c=d
	d = psutil.cpu_percent(interval=3, percpu=True)
	ctr1 = ctr1 + 1
	newtext = str(a[0])+","+str(a[1])+","+str(a[2])+","+str(a[3])+","+str(ctr1)+","+str(b[0])+","+str(b[1])+","+str(b[2])+","+str(b[3])+","+str(ctr1)+","+str(c[0])+","+str(c[1])+","+str(c[2])+","+str(c[3])+","+str(ctr1)+","+str(d[0])+","+str(d[1])+","+str(d[2])+","+str(d[3])+","+str(ctr1)
	text_file = open("core_usage_rpi.inc","w+r")
	text_file.write(newtext)
	text_file.close()
        #---
        
        deadline_logger_record_core_usage_rpi = open("deadline_logger_record_core_usage_rpi.inc","w+r")
        current_time = time.clock()
        difference = current_time - previous_time
        percentage_val = int ((difference-DEADLINE)/difference*100)
        #print "rec:"+str(difference)
        #print percentage_val
        if (difference > DEADLINE):
                deadline_logger_record_core_usage_rpi.write('1 '+str(percentage_val))
        else:
                deadline_logger_record_core_usage_rpi.write('0 '+str(percentage_val))
        deadline_logger_record_core_usage_rpi.close()
        previous_time = current_time
        
	#time.sleep(3) #App runs with 3sec period still
