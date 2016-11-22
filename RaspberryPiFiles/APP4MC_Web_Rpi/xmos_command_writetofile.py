#!/usr/bin/env python
import psutil
import time
import string
import sys
#import os 
arguments = sys.argv
#os.system("halt")
if (arguments[1]):
	new_command = arguments[1]
	text_file = open("ethernet_command_to_xmos_history.inc","r")
	prev_command = text_file.read().replace('\n','')
	print prev_command
	if (new_command != prev_command):
		write_new_command = 1
	else:
		write_new_command = 0
	text_file.close()
	text_file2 = open ("ethernet_command_to_xmos.inc","w")
	if (write_new_command == 1):
		text_file3 = open("ethernet_command_to_xmos_history.inc","w")
	if (write_new_command == 1):
		text_file2.write(new_command)
		text_file3.write(new_command)
	else:
		text_file2.write("NOCHANGE")

	text_file2.close()
	if (write_new_command == 1):
		text_file3.close()

