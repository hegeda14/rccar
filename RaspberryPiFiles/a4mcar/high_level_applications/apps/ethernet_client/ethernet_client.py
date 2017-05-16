#!/usr/bin/env python

# Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Description:
#    A4MCAR Project - High-level Module Ethernet Client Application
#
# Author:
#    M. Ozcelikors <mozcelikors@gmail.com>

import psutil
import time
import string
import socket
import select
import sys
import threading

client_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_sock.setblocking(0)
client_sock.settimeout(2)
connected = 0
done = False

#Timing Related ---start
_DEADLINE = 0.01
_START_TIME = 0
_END_TIME = 0
_EXECUTION_TIME = 0                  
_PREV_SLACK_TIME = 0
_PERIOD = 0.01
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



def Thread_EthernetClient_ReceiveMessage():
	global client_sock
	global connected
	global done
	data = ""
	while not done:
		if (connected == 1):
			ready = select.select([client_sock], [], [], 1)
			if ready [0]:
				dat = ""
				while (dat != "E"):
					dat = client_sock.recv(1)
					if (dat != "E"):
						data += dat
				#print data
				WriteToFile(data)
				data = ""
		time.sleep(0.5)

def Thread_EthernetClient_SendMessage():
	global client_sock
	global connected
	global done
	prevfiledata = "NOCHANGE"
	while not done:
		if (connected == 1):
			filedata = ReadFromFile()
			if (filedata != "NOCHANGE" and filedata != prevfiledata):
				client_sock.sendall(filedata)
				prevfiledata = filedata
			time.sleep(0.01)

def ReadFromFile():
	try:
		target = open ('../../logs/driving/driving_command.inc','r')
		dataread = target.read()
		target.close()
	except Exception as inst:
		print inst
		dataread = "FAILEDTOREAD"
	return dataread

def WriteToFile(data):
	try:
		target = open ('/var/www/html/core_usage_xmos.inc','w')
		target.write(data)
		target.close()
	except Exception as inst:
		print inst 

server_address = ('192.168.20.60',15534)

data = ""

threading.Thread(target=Thread_EthernetClient_ReceiveMessage).start()

prevfiledata = "NOCHANGE"

while not done:
	try:
		client_sock.connect(server_address)
		connected = 1
	except Exception as inst:
		print inst
	finally:
		if (connected == 0):
			print "Connection Unsuccessful"

	if (connected == 1):
		while not done:
			#Timing Related ---start
			_START_TIME = time.time()
			_PREV_SLACK_TIME = _START_TIME - _END_TIME
			#Timing Related --end

			try:
				filedata = ReadFromFile()
				if (filedata != "NOCHANGE" and filedata != prevfiledata):
					client_sock.sendall(filedata)
					prevfiledata = filedata
			except Exception as inst:
				done = True
                        
			#Timing Related ---start
			CreateTimingLog("../../logs/timing/ethernet_client_timing.inc")
			#Timing Related ---end

			if (_PERIOD>_EXECUTION_TIME):
				time.sleep(_PERIOD - _EXECUTION_TIME)