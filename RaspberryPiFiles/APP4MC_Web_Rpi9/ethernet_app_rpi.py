#!/usr/bin/env python
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
_DEADLINE = 0.2
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
		target = open ('ethernet_command_to_xmos.inc','r')
		dataread = target.read()
		target.close()
	except Exception as inst:
		print inst
		dataread = "FAILEDTOREAD"
	return dataread

def WriteToFile(data):
	try:
		target = open ('core_usage_xmos.inc','w')
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
                        
                        #---
			try:
				filedata = ReadFromFile()
                        	if (filedata != "NOCHANGE" and filedata != prevfiledata):
                                	client_sock.sendall(filedata)
					prevfiledata = filedata
			except Exception as inst:
				done = True
                        #---
                        
                        #Timing Related ---start
                        CreateTimingLog("deadline_logger_ethernet_app_rpi.inc")
                        #Timing Related ---end

                        #print _EXECUTION_TIME
                        if (_PERIOD>_EXECUTION_TIME):
                                time.sleep(_PERIOD - _EXECUTION_TIME)

