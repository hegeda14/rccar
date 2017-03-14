#!/usr/bin/env python
import psutil
import time
import string
import socket
import select
import sys
import threading

import os
import subprocess
import signal

client_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_sock.setblocking(0)
client_sock.settimeout(2)
connected = 0
done = False
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
                                print data
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

server_address = ('192.168.20.48',15534)

data = ""

threading.Thread(target=Thread_EthernetClient_ReceiveMessage).start()

prevfiledata = "NOCHANGE"





try:
	client_sock.connect(server_address)
	connected = 1
except Exception as inst:
	print inst

perf = subprocess.Popen(["perf","stat","-p",str(os.getpid())],stderr=subprocess.PIPE)
if (connected == 0):
	print "Connection Unsuccessful"
if (connected == 1):
        try:
                filedata = ReadFromFile()
                
                client_sock.sendall(filedata)
                prevfiledata = filedata

                if os.fork():
                        time.sleep(0.1)
                        perf.send_signal(signal.SIGINT)
                        exit (0)

                print ("got perf stats>>{}<<".format(perf.stderr.read().decode("utf-8")))
        except Exception as inst:
                done = True
                #time.sleep(0.1)
                
