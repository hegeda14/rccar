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

def Thread_EthernetClient_ReceiveMessage():
	global client_sock
	global connected
	data = ""
	while True:
		if (connected == 1):
                        ready = select.select([client_sock], [], [], 1)
                        if ready [0]:
                                dat = ""
                                while (dat != "E"):
                                        dat = client_sock.recv(1)
                                        if (dat != "E"):
                                                data += dat
                                WriteToFile(data)
                                data = ""
		time.sleep(0.01)


def Thread_EthernetClient_SendMessage():
	global client_sock
	global connected
        prevfiledata = "NOCHANGE"
	while True:
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

server_address = ('192.168.20.48',15534)

data = ""

threading.Thread(target=Thread_EthernetClient_ReceiveMessage).start()

prevfiledata = "NOCHANGE"

while True:
	try:
		client_sock.connect(server_address)
		connected = 1
	except Exception as inst:
		print inst
	finally:
		if (connected == 0):
			print "Connection Unsuccessful"

	if (connected == 1):
		while True:
			filedata = ReadFromFile()
                        if (filedata != "NOCHANGE" and filedata != prevfiledata):
                                client_sock.sendall(filedata)
				prevfiledata = filedata
                        #time.sleep(0.1)

