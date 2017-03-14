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

	#time.sleep(3) #App runs with 3sec period still
