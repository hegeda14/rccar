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

DEADLINE = 0.002#0.002
current_time = 0
previous_time = 0

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

                        #---
			try:
				filedata = ReadFromFile()
                        	if (filedata != "NOCHANGE" and filedata != prevfiledata):
                                	client_sock.sendall(filedata)
					prevfiledata = filedata
			except Exception as inst:
				done = True
                        #---
                        
                        deadline_logger_ethernet_app_rpi = open("deadline_logger_ethernet_app_rpi.inc","w+r")
                        current_time = time.clock()
                        difference = current_time - previous_time
                        percentage_val = int((difference-DEADLINE)/difference*100)
                        #print "eth:"+str(difference)
                        if (difference > DEADLINE):
                                deadline_logger_ethernet_app_rpi.write('1 '+str(percentage_val))
                        else:
                                deadline_logger_ethernet_app_rpi.write('0 '+str(percentage_val))
                        deadline_logger_ethernet_app_rpi.close()
                        previous_time = current_time
                        
                        time.sleep(0.01)
