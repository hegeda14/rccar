#!/usr/bin/env python
import psutil
import time
import string

while True:
	a = psutil.cpu_percent(interval=2, percpu=True)
	newtext = str(a[0])+","+str(a[1])+","+str(a[2])+","+str(a[3])
	text_file = open("core_usage_rpi.inc","w+r")
	text_file.write(newtext)
	text_file.close()
	time.sleep(1)
