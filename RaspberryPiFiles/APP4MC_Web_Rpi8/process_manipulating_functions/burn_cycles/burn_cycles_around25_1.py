#!/usr/bin/env python
import psutil
import time
import string
import numpy

a= 9999999999999

#---
DEADLINE = 0.42#0.40 # 0.42
current_time = 0
previous_time = 0
#---


while True:
        #a=a/2
        a=numpy.random.random([1000,1000])
        b=numpy.random.random([1000,1000])
        c=numpy.mean(a*b)
        #---
        deadline_logger_burn_cycles_around25_1 = open("deadline_logger_burn_cycles_around25_1.inc","w+r")
        current_time = time.clock()
        difference = current_time - previous_time
        percentage_val = int((difference-DEADLINE)/difference*100)
        #print "25_1:"+str(difference)

        
        
        if (difference > DEADLINE):
                deadline_logger_burn_cycles_around25_1.write('1 '+str(percentage_val))
        else:
                deadline_logger_burn_cycles_around25_1.write('0 '+str(percentage_val))

        deadline_logger_burn_cycles_around25_1.close()
                
        
        previous_time = current_time
	#---
	#time.sleep(0.00001)
        time.sleep(1)