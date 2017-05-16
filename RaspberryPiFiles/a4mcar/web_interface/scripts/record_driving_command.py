#!/usr/bin/env python

# Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Description:
#    A4MCAR Project - This Python script is used for writing driving command log, given its argument.
#
# Author:
#    M. Ozcelikors <mozcelikors@gmail.com>

import psutil
import time
import string
import sys

arguments = sys.argv

if (arguments[1]):
	new_command = arguments[1]
	text_file = open("/home/pi/a4mcar/high_level_applications/logs/driving/driving_command_history.inc","r")
	prev_command = text_file.read().replace('\n','')
	#print prev_command
	if (new_command != prev_command):
		write_new_command = 1
	else:
		write_new_command = 0
	text_file.close()
	text_file2 = open ("/home/pi/a4mcar/high_level_applications/logs/driving/driving_command.inc","w")
	if (write_new_command == 1):
		text_file3 = open("/home/pi/a4mcar/high_level_applications/logs/driving/driving_command_history.inc","w")
	if (write_new_command == 1):
		text_file2.write(new_command)
		text_file3.write(new_command)
	else:
		text_file2.write("NOCHANGE")

	text_file2.close()
	if (write_new_command == 1):
		text_file3.close()

