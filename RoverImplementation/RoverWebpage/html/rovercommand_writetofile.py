#!/usr/bin/env python
import time
import string
import sys

arguments = sys.argv

if (arguments[1]):
	new_command = arguments[1].strip('\n').strip(' ')
	text_file = open("ROVER_CMD.inc","w+r")
	text_file.write(str(new_command))
	text_file.close()


