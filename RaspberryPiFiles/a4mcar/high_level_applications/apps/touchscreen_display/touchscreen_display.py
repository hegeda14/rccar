#!/usr/bin/env python

# Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Description:
#    A4MCAR Project - Touchscreen display process utilizes the touchscreen display of the A4MCAR high-level module
#			and includes necessary operations to make use of A4MCAR's online timing features
#
# Author:
#    M. Ozcelikors <mozcelikors@gmail.com>

import pygame
import aprocess
from pygame.locals import * #for backspace key
import sys
import os
import socket
import string
import math
import datetime
import time
import socket
import select
import RPi.GPIO as GPIO
import threading
import subprocess #for Popen
import serial #pyserial
import glob #For listing serial ports
import fcntl  # For getting ip function
import struct # For getting ip function
from time import localtime, strftime
import virtkeyboard
import netinfo     #How Pynetinfo package imported. To install run pip install X.tar.gz to package, first.
import re #regex for ssid, psk retrieval
import psutil

#Virtual Keyboard related definitions
mykeys = virtkeyboard.VirtualKeyboard()
mykeyboard_inputtext=""

#Network settings related definitions
current_static_ip = ""
current_gateway = ""
current_ssid = ""
current_psk = ""
prev_psk = ""
prev_ssid = ""
previous_gateway = ""
previous_static_ip = ""

#Core usage variables
core_usage_tile0 = [0,0,0,0,0,0,0,0]
core_usage_tile1 = [0,0,0,0,0,0,0,0]
core_usage_rpi = [0,0,0,0]

#Coordinates for text elements
coord_x = [30,  30,  30,  30,  30,  30,  30, 380, 380, 380, 380, 380, 380, 380]
coord_y = [120,170, 220, 270, 320, 370, 420, 120, 170, 220, 270, 320, 370, 420]

#Process definitions
aprocess_list = []
aprocess_list.append(aprocess.aprocess("Xtightvnc", 0, "None", 1, "VNC Server", "cd ../../scripts/tightvnc/  && sudo bash tightvnc_start.sh &"))
aprocess_list.append(aprocess.aprocess("mjpg_streamer", 0, "None",1, "Camera Stream", "cd ../../scripts/camera_start/  && sudo bash raspberrypi_camera_start.sh &"))
aprocess_list.append(aprocess.aprocess("touchscreen_display", 1, "../../logs/timing/touchscreen_display_timing.inc", 1, "Display", "None"))
aprocess_list.append(aprocess.aprocess("ethernet_client", 1, "../../logs/timing/ethernet_client_timing.inc", 1, "Ethernet App", "cd ../ethernet_client/ && sudo python ethernet_client.py &"))
aprocess_list.append(aprocess.aprocess("core_recorder", 1, "../../logs/timing/core_recorder_timing.inc", 1, "Core Recorder", "cd ../core_recorder/ && sudo python core_recorder.py &"))
aprocess_list.append(aprocess.aprocess("dummy_load25_1", 1, "../../logs/timing/dummy_load25_1_timing.inc", 1, "Cycler25_1", "cd ../dummy_loads/ && sudo python dummy_load25_1.py &"))
aprocess_list.append(aprocess.aprocess("dummy_load25_2", 1, "../../logs/timing/dummy_load25_2_timing.inc", 1, "Cycler25_2", "cd ../dummy_loads/ && sudo python dummy_load25_2.py &"))
aprocess_list.append(aprocess.aprocess("dummy_load25_3", 1, "../../logs/timing/dummy_load25_3_timing.inc", 1, "Cycler25_3", "cd ../dummy_loads/ && sudo python dummy_load25_3.py &"))
aprocess_list.append(aprocess.aprocess("dummy_load25_4", 1, "../../logs/timing/dummy_load25_4_timing.inc", 1, "Cycler25_4", "cd ../dummy_loads/ && sudo python dummy_load25_4.py &"))
aprocess_list.append(aprocess.aprocess("dummy_load25_5", 1, "../../logs/timing/dummy_load25_5_timing.inc", 1, "Cycler25_5", "cd ../dummy_loads/ && sudo python dummy_load25_5.py &"))
aprocess_list.append(aprocess.aprocess("dummy_load100", 1, "../../logs/timing/dummy_load100_timing.inc", 1, "Cycler100", "cd ../dummy_loads/ && sudo python dummy_load100.py &"))
aprocess_list.append(aprocess.aprocess("apache2", 0, "None", 1, "Apache Server", "sudo service apache2 start"))
#aprocess_list.append(aprocess.aprocess("image_processing", 1, "../../logs/timing/image_processing_timing.inc", 1, "ImageProcess", "cd ../image_processing/ && sudo -E ./image_processing &"))
aprocess_list_len = len(aprocess_list)


#Software Distribution Type
#1- APP4MC Distribution (Uses coredef_list.a4p)
#2- Automatic (OS) Distribution
#3- Sequential Distribution (Every process on core 3)
distribution_type = 2

#Timing Related ---start
_DEADLINE = 0.1
_START_TIME = 0
_END_TIME = 0
_EXECUTION_TIME = 0                  
_PREV_SLACK_TIME = 0
_PERIOD = 0.2
#Timing Related ---end

#For timing calculations, missed deadlines, total processes, and slack time sum
missed=0
total=0
slack_sum=0.0
gross_execution_time=0.0

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


def get_image(path):
	global _image_library
	image = _image_library.get(path)
	if image == None:
		canonicalized_path = path.replace('/', os.sep).replace('\\', os.sep)
		image = pygame.image.load(canonicalized_path)
		_image_library[path] = image
	return image

def GetMyGateway():
	#return "192.168.1.1"
	#for route in netinfo.get_routes():
	#	return route['gateway']
	try:
		return "192.168."+str(netinfo.get_ip('wlan0')[8:9])+".1"
	except Exception as inst:
		return "NotFound"

def GetMySSID():
	#Only one ssid and psk allowed in wpa_supplicant.conf for this version
	global current_ssid
	with open('/etc/wpa_supplicant/wpa_supplicant.conf', 'r') as myfile:
		myfile_str = myfile.read()#.replace('\n','')
		myfile.close()
	#print myfile_str
	m = re.search('ssid=\"(.*?)\"', myfile_str)
	return m.group(1)

def GetMyPSK():
	#Only one ssid and psk allowed in wpa_supplicant.conf for this version
	global current_psk
	with open('/etc/wpa_supplicant/wpa_supplicant.conf', 'r') as myfile:
		myfile_str = myfile.read()#.replace('\n','')
		myfile.close()
	#print myfile_str
	m = re.search('psk=\"(.*?)\"', myfile_str)
	return m.group(1)

def GetMyIPAddress(ifname): #ifname: eth0 wlan0 etc.
	try:
		s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		return socket.inet_ntoa(fcntl.ioctl(
			s.fileno(),
			0x8915,  # SIOCGIFADDR
			struct.pack('256s', ifname[:15])
		)[20:24])
		#return netinfo.get_ip('eth0') # Can be used for IP using netinfo module
	except Exception as inst:
		return "NotFound"

def Settings_IsValidIPv4Address(address):
	try:
		socket.inet_pton(socket.AF_INET, address)
	except AttributeError:
		try:
			socket.inet_aton(address)
		except socket.error:
			return False
		return address.count('.') == 3
	except socket.error:
		return False

	return True

def Clear_Variables():
	global mykeyboard_inputtext
	global current_static_ip
	global current_gateway
	global current_ssid
	global current_psk

	print "Cleared variables"
	mykeyboard_inputtext=""
	current_static_ip = GetMyIPAddress('eth0')
	current_gateway = GetMyGateway()
	current_ssid = GetMySSID()
	current_psk = GetMyPSK()
	return 1

def HomePage():
	Clear_Variables()
	print "HomePage"
	screen.blit(get_image('images/display_r1_c1_s1.png'),(0,0))    
	screen.blit(get_image('images/coresimg.png'),(0,175))    
	screen.blit(get_image('images/display_r1_c2_s1.png'),(710,0))    
	screen.blit(get_image('images/display_r2_c2_s1.png'),(710,94))
	screen.blit(get_image('images/display_r4_c2_s1.png'),(710,184)) 
	screen.blit(get_image('images/display_r5_c2_s1.png'),(710,294))
	screen.blit(get_image('images/display_r5_c2_s2.png'),(710,378))
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("System Core Utilization", True, (255, 255, 255))
	screen.blit(text,(30,30))
	return 1

def DeadlineMissPage():
	Clear_Variables()
	print "DeadlineMissPage"
	screen.blit(get_image('images/display_r1_c1_s1.png'),(0,0))    
	screen.blit(get_image('images/coresimg.png'),(0,175))    
	screen.blit(get_image('images/display_r1_c2_s1.png'),(710,0))    
	screen.blit(get_image('images/display_r2_c2_s1.png'),(710,94))
	screen.blit(get_image('images/display_r4_c2_s1.png'),(710,184)) 
	screen.blit(get_image('images/display_r5_c2_s1.png'),(710,294))
	screen.blit(get_image('images/display_r5_c2_s2.png'),(710,378))
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Core Utilization", True, (255, 255, 255))
	screen.blit(text,(30,30))
	return 1

def UpdateSettingsPageValues():
	global current_static_ip
	global current_gateway
	global current_ssid
	global current_psk

	AddPromptBox_Passive(220, 120, 250, 40)
	AddPromptBox_Passive(220, 170, 250, 40)
	AddPromptBox_Passive(220, 220, 250, 40)
	AddPromptBox_Passive(220, 270, 250, 40)
	font = pygame.font.SysFont("Roboto Condensed", 20)

	text = font.render (str(current_static_ip), True, (255, 255, 255))
	screen.blit(text,(225,125))

	text = font.render (str(current_gateway), True, (255, 255, 255))
	screen.blit(text,(225,175))

	text = font.render (str(current_ssid), True, (255, 255, 255))
	screen.blit(text,(225,225))

	text = font.render (str(current_psk), True, (255, 255, 255))
	screen.blit(text,(225,275))

def SettingsPage():
	Clear_Variables()
	
	print "SettingsPage"
	screen.blit(get_image('images/settingsypm_r1_c1_s1.png'),(0,0))    
	screen.blit(get_image('images/display_r3_c1_s1.png'),(0,175))    
	screen.blit(get_image('images/display_r1_c2_s1.png'),(710,0))    
	screen.blit(get_image('images/display_r2_c2_s1.png'),(710,94))
	screen.blit(get_image('images/display_r4_c2_s1.png'),(710,184)) 
	screen.blit(get_image('images/display_r5_c2_s1.png'),(710,294))
	screen.blit(get_image('images/display_r5_c2_s2.png'),(710,378))
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Settings", True, (255, 255, 255))
	screen.blit(text,(30,30))

	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Static IP", True, (0, 0, 0))
	screen.blit(text,(30,120))
	AddPromptBox_Passive(220, 120, 250, 40)

	text = font.render ("Gateway", True, (0, 0, 0))
	screen.blit(text,(30,170))
	AddPromptBox_Passive(220, 170, 250, 40)

	text = font.render ("SSID", True, (0, 0, 0))
	screen.blit(text,(30,220))
	AddPromptBox_Passive(220, 220, 250, 40)

	text = font.render ("PSK", True, (0, 0, 0))
	screen.blit(text,(30,270))
	AddPromptBox_Passive(220, 270, 250, 40)

	screen.blit(get_image('images/savechanges.png'),(243,330))

	UpdateSettingsPageValues()

	return 1

def CheckIfProcessRunning(process_name):
	# Returns process id, or 0 if process not running
	try:
		x = subprocess.check_output(['pgrep','-f',process_name,'-n']) #,'-u','root'
	except Exception as inst:
		x = 0
	return x

def GetProcessCoreAffinityList(pid):
	#Returns which core the process is running on
	cmd = ['taskset','-c','-p',str(pid).strip('\n')]
	try:
		x = subprocess.check_output(cmd, shell=False, stderr=subprocess.STDOUT)
		affinity_list = x.split(':')[1].strip('\n')
	except Exception as inst:
		#print inst
		affinity_list = "NaN"

	return affinity_list

def UpdateProcessInfo():
	global aprocess_list
	global aprocess_list_len

	for i in range(0,aprocess_list_len):
		aprocess_list[i].UpdateProcessIDAndRunning()
	
def ChangeDistributionPage():
	Clear_Variables()
	
	print "ChangeDistributionPage"
	screen.blit(get_image('images/settingsypm_r1_c1_s1.png'),(0,0))    
	screen.blit(get_image('images/display_r3_c1_s1.png'),(0,175))    
	screen.blit(get_image('images/display_r1_c2_s1.png'),(710,0))    
	screen.blit(get_image('images/display_r2_c2_s1.png'),(710,94))
	screen.blit(get_image('images/display_r4_c2_s1.png'),(710,184)) 
	screen.blit(get_image('images/display_r5_c2_s1.png'),(710,294))
	screen.blit(get_image('images/display_r5_c2_s2.png'),(710,378))
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Change Rpi App Distribution", True, (255, 255, 255))
	screen.blit(text,(30,30))
	
	AddPromptBox_Passive(220, 280, 350, 40)
	text = font.render (" Automatic (OS) Distribution", True, (0, 0, 0))
	screen.blit(text,(220,280))
	
	AddPromptBox_Passive(220, 340, 350, 40)
	text = font.render (" APP4MC Parallel Distribution", True, (0, 0, 0))
	screen.blit(text,(220,340))

	AddPromptBox_Passive(220, 220, 350, 40)
	text = font.render (" Sequential Distribution", True, (0, 0, 0))
	screen.blit(text,(220,220))
	return 1

def UpdateChangeDistributionPage():
	global distribution_type
	screen.blit(get_image('images/display_r3_c1_s1.png'),(0,175)) 

	if (distribution_type == 2):
		colorc =(0,255,0)
	else:
		colorc=(0,0,0)

	font = pygame.font.SysFont("Roboto Condensed", 30)
	AddPromptBox_Passive(220, 280, 350, 40)
	text = font.render (" Automatic (OS) Distribution", True, colorc)
	screen.blit(text,(220,280))
	
	if (distribution_type == 1 or distribution_type == -1):
		colorc =(0,255,0)
	else:
		colorc=(0,0,0)
	AddPromptBox_Passive(220, 340, 350, 40)
	text = font.render (" APP4MC Parallel Distribution", True, colorc)
	screen.blit(text,(220,340))

	if (distribution_type == 3):
		colorc =(0,255,0)
	else:
		colorc=(0,0,0)
	AddPromptBox_Passive(220, 220, 350, 40)
	text = font.render (" Sequential Distribution", True, colorc)
	screen.blit(text,(220,220))

	return 1 


def UpdateShowDistributionPage():
	global aprocess_list
	global aprocess_list_len
	
	global distribution_type

	global total
	global missed
	global slack_sum
	global gross_execution_time
        
	global _PERIOD
	global _PREV_SLACK_TIME
	global _EXECUTION_TIME
	global _START_TIME
	global _END_TIME
	global _DEADLINE

	#Timing Related --start
	_START_TIME = time.time()
	_PREV_SLACK_TIME = _START_TIME - _END_TIME
	
	#TASK CONTENT
	screen.blit(get_image('images/display_r3_c1_s1.png'),(0,175))

	#Show CPU Frequencies and CPU Count
	font = pygame.font.SysFont("Roboto Condensed", 20)

	text = font.render ("Gross Execution Time:", True, (0,0,255))
	screen.blit(text,(50,281))

	text = font.render ("Core Frequencies at:", True, (0,0,255))
	screen.blit(text,(50,302))

	text = font.render ("Total Deadlines Missed:", True, (0,0,255))
	screen.blit(text,(50,323))

	text = font.render("Cores Running:", True, (0,0,255))
	screen.blit(text,(400,302))

	text = font.render("Traceable Processes Running:", True, (0,0,255))
	screen.blit(text,(400,323))

	

	text = font.render (str(psutil.cpu_freq()).split(',')[0].split('=')[1]+" MHz", True, (0,0,0))
	screen.blit(text, (220,302))

	text = font.render (str(psutil.cpu_count()), True, (0,0,0))
	screen.blit(text, (530,302))

	

	#deadline variables: missed count: missed total, count: total
	missed = 0
	total = 0
	slack_sum = 0.0
	gross_execution_time = 0.0

	# Updates for display app
	total = total + 1
	slack_sum = slack_sum + _PREV_SLACK_TIME
	gross_execution_time = gross_execution_time + round(_EXECUTION_TIME,2)

	if (_EXECUTION_TIME > _PERIOD):
		missed = missed + 1
        
	# Updates from other apps
	differences_list = []

	for i in range(0,aprocess_list_len):
		aprocess_list[i].UpdateProcessIDAndRunning()
		if (aprocess_list[i].apname != "touchscreen_display" and aprocess_list[i].traceable == 1 and aprocess_list[i].aprunning == 1):
			try:
				file_obj = open(aprocess_list[i].aplogfilepath,"r")
				data_obj = file_obj.read()
				int_objs = data_obj.split(' ')
				exectime_l = float(int_objs[1])
				period_l = float (int_objs[2])
				slack_l = float (int_objs[0])
				if (exectime_l>period_l):
					missed = missed + 1
				
				differences_list.append(float(exectime_l)) #i.e. execution time list
				slack_sum = slack_sum + slack_l
				gross_execution_time = gross_execution_time + round(exectime_l,2)
				total = total + 1
				#print int_objs
				file_obj.close()
			except Exception as inst:
				#print inst
				debug = 1

	#Traceable Processes running
	text = font.render (str(total), True, (0,0,0))
	screen.blit(text, (640,323))

	#Total Deadlines Missed
	text = font.render (str(missed), True, (0,0,0))
	screen.blit(text, (250,323))

	#Gross Execution Time
	text = font.render (str(gross_execution_time)+"s", True, (0,0,0))
	screen.blit(text,(240,281))

	slack_avg = slack_sum / total
	deadline_missed_percentage = int((missed*100)/total)
        
	font = pygame.font.SysFont("Roboto Condensed", 60)
			 
	text = font.render (str(slack_avg)[0:8]+"s", True, (0, 0, 0))
	screen.blit(text,(40,180))
	pygame.display.flip()

	text = font.render (str(deadline_missed_percentage)[0:5]+"%", True, (0, 0, 0))
	screen.blit(text,(400,180))
	pygame.display.flip()

	if(distribution_type == 0):
		font = pygame.font.SysFont("Roboto Condensed", 40)
		text = font.render ("Distribution: No distribution selected", True, (0, 0, 0))
		screen.blit(text,(50,350))
	elif(distribution_type == 1):
		font = pygame.font.SysFont("Roboto Condensed", 40)
		text = font.render ("Distribution: APP4MC Distribution", True, (0, 0, 0))
		screen.blit(text,(50,350))
	elif(distribution_type == 2):
		font = pygame.font.SysFont("Roboto Condensed", 40)
		text = font.render ("Distribution: Automatic (OS) Distribution", True, (0, 0, 0))
		screen.blit(text,(50,350))
	elif(distribution_type == 3):
		font = pygame.font.SysFont("Roboto Condensed", 40)
		text = font.render ("Distribution: Sequential Distribution", True, (0, 0, 0))
		screen.blit(text,(50,350))

	#TimingRelated --start
	CreateTimingLog("../../logs/timing/touchscreen_display_timing.inc")
	#TimingRelated --end

def AutomaticDistributionActions():
	global aprocess_list
	global aprocess_list_len
	
	UpdateProcessInfo()

	for i in range(0,aprocess_list_len):
		aprocess_list[i].SetCoreAffinity("0-3")
		
def GetProcessIDFromProcessName(process_name):
	# Returns process id, or 0 if process not running
	try:
		x = subprocess.check_output(['pgrep','-f',process_name,'-n']) #,'-u','root'
	except Exception as inst:
		x = 0
	return x
	
def AllocateProcessWithCore(process_name, core):
	global aprocess_list
	global aprocess_list_len

	pid = GetProcessIDFromProcessName(process_name)

	if (pid != ""):
		try:
			os.system("sudo taskset -pc "+core+" "+pid)
			for i in range(0,aprocess_list_len):
				if (process_name == aprocess_list[i].apname):
					aprocess_list[i].aaffinity = core
		except Exception as inst:
			debug = 1
     
def APP4MCDistributionActions():
	try:
		with open('../../logs/core_mapping/coredef_list.a4p','rb') as coredef_list:
			for line in coredef_list:
				words = line.strip('\n').split(' ')
				if (len(words)>3):
					try:
						AllocateProcessWithCore(words[2], words[5])
					except Exception as inst:
						debug = 1
	except Exception as inst:
		debug = 1

def SequentialDistributionActions():
	global aprocess_list
	global aprocess_list_len
	
	UpdateProcessInfo()

	for i in range(0,aprocess_list_len):
		aprocess_list[i].SetCoreAffinity("3")

def ShowDistributionPage():
	Clear_Variables()
	
	print "ShowDistributionPage"
	screen.blit(get_image('images/settingsypm_r1_c1_s1.png'),(0,0))    
	screen.blit(get_image('images/display_r3_c1_s1.png'),(0,175))    
	screen.blit(get_image('images/display_r1_c2_s1.png'),(710,0))    
	screen.blit(get_image('images/display_r2_c2_s1.png'),(710,94))
	screen.blit(get_image('images/display_r4_c2_s1.png'),(710,184)) 
	screen.blit(get_image('images/display_r5_c2_s1.png'),(710,294))
	screen.blit(get_image('images/display_r5_c2_s2.png'),(710,378))
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Show Timing Performance", True, (255, 255, 255))
	screen.blit(text,(30,30))

	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Slack Time Average:", True, (0, 0, 255))
	screen.blit(text,(40,130))
	text = font.render ("Deadline Misses:", True, (0, 0, 255))
	screen.blit(text,(400,130))
        
	UpdateShowDistributionPage()
	return 1

def UpdateAllocationPage():
	global aprocess_list
	global aprocess_list_len
	global coord_x
	global coord_y
	
	#Red and green color
	color_red = ((255,0,0))
	color_green = ((34,139,34))
	
	#Font definition
	font = pygame.font.SysFont("Roboto Condensed", 30)
	
	UpdateProcessInfo()
	
	for i in range(0,aprocess_list_len):
		if (aprocess_list[i].aprunning == 1):
			colorc = color_green
		else:
			colorc = color_red
		text = font.render (str(aprocess_list[i].display_name), True, colorc)
		screen.blit(text,(coord_x[i],coord_y[i]))


def KillProcess(process_name):
	pid = GetProcessIDFromProcessName(process_name)
	if (process_name == "apache2"):
		try:
			os.system("sudo service apache2 stop &")
		except Exception as inst:
			print inst
	else:
		try:
			os.system("sudo kill -9 "+pid)
		except Exception as inst:
			print inst

def GetCoreAffinityFromPID (pid):
	cmd = ['taskset','-c','-p', str(pid) .strip('\n')]
	try:
		x = subprocess.check_output(cmd, shell=False, stderr=subprocess.STDOUT)
		affinity_list = x.split(':')[1].strip('\n')
	except Exception as inst:
		#print inst
		affinity_list = "NaN"
	return affinity_list
          
def AllocateProcess(process_name):
	global aprocess_list
	global aprocess_list_len
	pid = GetProcessIDFromProcessName(process_name)
	core = mykeys.run(screen, GetCoreAffinityFromPID (pid))

	try:
		os.system("sudo taskset -pc "+core+" "+pid)
		for i in range(0,aprocess_list_len):
			if (process_name == aprocess_list[i].apname):
				aprocess_list[i].aaffinity = core
	except Exception as inst:
 		print "Err-AllocateProcess"

	

def StartProcess(process_name):
	global aprocess_list
	global aprocess_list_len
	
	for i in range(0,aprocess_list_len):
		if (process_name == aprocess_list[i].apname):
			try:
				os.system(str(aprocess_list[i].apstartcommand))
			except Exception as inst:
				print "Err-StartProcess"
                                
	# & at the end in commands is important to run the app in the background
	
def AllocationPage():
	global aprocess_list
	global aprocess_list_len
	global coord_x
	global coord_y
	
	Clear_Variables()
	
	print "AllocationPage"
	screen.blit(get_image('images/settingsypm_r1_c1_s1.png'),(0,0))    
	screen.blit(get_image('images/display_r3_c1_s1.png'),(0,175))    
	screen.blit(get_image('images/display_r1_c2_s1.png'),(710,0))    
	screen.blit(get_image('images/display_r2_c2_s1.png'),(710,94))
	screen.blit(get_image('images/display_r4_c2_s1.png'),(710,184)) 
	screen.blit(get_image('images/display_r5_c2_s1.png'),(710,294))
	screen.blit(get_image('images/display_r5_c2_s2.png'),(710,378))
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Start/Kill Rpi Processes", True, (255, 255, 255))
	screen.blit(text,(30,30))
	
	UpdateProcessInfo()
	
	for i in range(0,aprocess_list_len):
		font = pygame.font.SysFont("Roboto Condensed", 30)
		text = font.render (str(aprocess_list[i].display_name), True, (0, 0, 0))
		screen.blit(text,(coord_x[i],coord_y[i]))
		font = pygame.font.SysFont("Roboto Condensed", 20)
		AddPromptBox_Passive(coord_x[i]+180, coord_y[i], 60, 40)
		text = font.render ("Start", True, (255, 0, 0))
		screen.blit(text,(coord_x[i]+190,coord_y[i]+10))
		AddPromptBox_Passive(coord_x[i]+250, coord_y[i], 50, 40)
		text = font.render ("Kill", True, (255, 0, 0))
		screen.blit(text,(coord_x[i]+260,coord_y[i]+10))	
	
	return 1

def GetCoreInfoRpi():
	global aprocess_list
	global aprocess_list_len
	
	for i in range(0,aprocess_list_len):
		aprocess_list[i].UpdateProcessCoreAffinity()

def UpdateCoreAllocationPage():
	global aprocess_list
	global aprocess_list_len
	global coord_x
	global coord_y
	
	#UpdateProcessInfo()
	#GetCoreInfoRpi()
	
	#Red and green color
	color_red = ((255,0,0))
	color_green = ((34,139,34))
	
	for i in range(0,aprocess_list_len):
		if (aprocess_list[i].aprunning == 1):
			colorc = color_green
		else:
			colorc = color_red
		font = pygame.font.SysFont("Roboto Condensed", 30)
		text = font.render (str(aprocess_list[i].display_name), True, colorc)
		screen.blit(text,(coord_x[i], coord_y[i]))
		font = pygame.font.SysFont("Roboto Condensed", 20)
		AddPromptBox_Passive(coord_x[i]+180, coord_y[i], 60, 40)
		text = font.render (str(aprocess_list[i].aaffinity), True, (0, 0, 0))
		screen.blit(text,(coord_x[i]+190,coord_y[i]+10))

def CoreAllocationPage():
	global aprocess_list
	global aprocess_list_len
	global coord_x
	global coord_y
	
	Clear_Variables()
	
	print "CoreAllocationPage"
	screen.blit(get_image('images/settingsypm_r1_c1_s1.png'),(0,0))    
	screen.blit(get_image('images/display_r3_c1_s1.png'),(0,175))    
	screen.blit(get_image('images/display_r1_c2_s1.png'),(710,0))    
	screen.blit(get_image('images/display_r2_c2_s1.png'),(710,94))
	screen.blit(get_image('images/display_r4_c2_s1.png'),(710,184)) 
	screen.blit(get_image('images/display_r5_c2_s1.png'),(710,294))
	screen.blit(get_image('images/display_r5_c2_s2.png'),(710,378))
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Allocate Rpi Processes", True, (255, 255, 255))
	screen.blit(text,(30,30))
	
	for i in range(0,aprocess_list_len):
		font = pygame.font.SysFont("Roboto Condensed", 30)
		text = font.render (str(aprocess_list[i].display_name), True, (0, 0, 0))
		screen.blit(text,(coord_x[i],coord_y[i]))
		font = pygame.font.SysFont("Roboto Condensed", 20)
		AddPromptBox_Passive(coord_x[i]+180, coord_y[i], 60, 40)
		text = font.render ("", True, (0, 0, 0))
		screen.blit(text,(coord_x[i]+190,coord_y[i]+10))
		AddPromptBox_Passive(coord_x[i]+250, coord_y[i], 80, 40)
		text = font.render ("Allocate", True, (255, 0, 0))
		screen.blit(text,(coord_x[i]+260,coord_y[i]+10))

	return 1


def PercentagePage(): 
	Clear_Variables()
	print "PercentagePage"
	screen.blit(get_image('images/display_r1_c1_s1.png'),(0,0))    
	screen.blit(get_image('images/display_r3_c1_s1.png'),(0,175))    
	screen.blit(get_image('images/display_r1_c2_s1.png'),(710,0))    
	screen.blit(get_image('images/display_r2_c2_s1.png'),(710,94))
	screen.blit(get_image('images/display_r4_c2_s1.png'),(710,184)) 
	screen.blit(get_image('images/display_r5_c2_s1.png'),(710,294))
	screen.blit(get_image('images/display_r5_c2_s2.png'),(710,378))
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Average Utilization", True, (255, 255, 255))
	screen.blit(text,(30,30))
	return 1

def GetMyProcessID():
	pid = os.getpid()
	print "My ProcessID is: " + str(pid)
	return pid

def QuitFunction():
	os.system("kill -9 " + str(GetMyProcessID()))

def ShutdownSystem():
	screen.blit(get_image('images/shuttingdown.png'),(181,175))
	pygame.display.flip()
	time.sleep(3)
	os.system("halt")

def AddPromptBox_Passive(x, y, w, h):
	pygame.draw.rect(screen, ( 170, 170, 170), pygame.Rect(x, y, w, h))
	pygame.draw.rect(screen, (50,50,50), (x, y, w, h), 2)

def AddPromptBox_Active(x, y, w, h):
	pygame.draw.rect(screen, ( 190, 190, 190), pygame.Rect(x, y, w, h))
	pygame.draw.rect(screen, (255,0,0), (x, y, w, h), 2)

def EnterToTerminal2_SmallerTerminal(message):
	pygame.draw.rect(screen, ( 170, 170, 170), pygame.Rect(30, 400, 300, 45))
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render (str(message), True, (255, 0, 0))
	screen.blit(text,(30,400))
	
def Settings_NetworkSettingsOfDevice():
	global current_static_ip
	global current_gateway
	global previous_static_ip
	global previous_gateway
	global current_psk
	global prev_psk
	global prev_ssid
	global current_ssid
	# First, creates a file of \high_level_applications\logs\settings\new_interfaces.inc, copied from /etc/network/interfaces/
	# Then copies it to /etc/network/interfaces
	restart = 0
	if((current_static_ip!=previous_static_ip or current_gateway!=previous_gateway) and Settings_IsValidIPv4Address(current_static_ip) and Settings_IsValidIPv4Address(current_gateway)):
		try:
			target = open ('../../logs/settings/new_interfaces.inc','w')
			target.truncate()
			line1 = "source-directory /etc/network/interfaces.d"
			line2 = "auto lo"
			line3 = "iface lo inet loopback"
			line4 = "iface eth0 inet manual"
			line5 = "auto eth0"
			line6 = "iface eth0 inet static"
			line7 = "   address "+current_static_ip
			line8 = "   netmask 255.255.255.0"
			try: # for 192.168.XX....
				line9 = "   network 192.168."+str(int(current_static_ip[8:10]))+".1"
			except Exception as inst1: #for 192.168.X...
				line9 = "   network 192.168."+str(int(current_static_ip[8:9]))+".1"
			line10 = "   gateway "+current_gateway
			line11 = "   dns-nameservers 8.8.8.8 8.8.4.4"
			line12 = "allow-hotplug wlan0"
			line13 = "iface wlan0 inet manual"
			line14 = "   wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf"
			line15 = "allow-hotplug wlan1"
			line16 = "iface wlan1 inet manual"
			line17 = "   wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf"
			target.write(line1)
			target.write("\n")
			target.write(line2)
			target.write("\n")
			target.write(line3)
			target.write("\n")
			target.write(line4)
			target.write("\n")
			target.write(line5)
			target.write("\n")
			target.write(line6)
			target.write("\n")
			target.write(line7)
			target.write("\n")
			target.write(line8)
			target.write("\n")
			target.write(line9)
			target.write("\n")
			target.write(line10)
			target.write("\n")
			target.write(line11)
			target.write("\n")
			target.write(line12)
			target.write("\n")
			target.write(line13)
			target.write("\n")
			target.write(line14)
			target.write("\n")
			target.write(line15)
			target.write("\n")
			target.write(line16)
			target.write("\n")
			target.write(line17)
			target.write("\n")
		
			target.close()
		except Exception as inst:
			print inst
	
		try:
			os.system("cp ../../logs/settings/new_interfaces.inc /etc/network/interfaces")
		except Exception as inst:
			print inst
	
		restart = 1
	else:
		EnterToTerminal2_SmallerTerminal("IP addr or gateway")
		EnterToTerminal2_SmallerTerminal("Not valid.")

	if(prev_psk!=current_psk or prev_ssid!=current_ssid):
		
		try:
			target = open ('../../logs/settings/new_wpasupplicant.inc','w')
			target.write("country=GB")
			target.write("\n")
			target.write("ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev")
			target.write("\n")
			target.write("update_config=1")
			target.write("\n")
			target.write("\n")
			target.write("network={")
			target.write("\n")
			target.write("	ssid=\""+current_ssid+"\"")
			target.write("\n")
			target.write("	psk=\""+current_psk+"\"")
			target.write("\n")
			target.write("}")
			target.write("\n")

			target.close()
		except Exception as inst:
			print inst
	
		try:
			os.system("cp ../../logs/settings/new_wpasupplicant.inc /etc/wpa_supplicant/wpa_supplicant.conf")
		except Exception as inst:
			print inst
	
		restart = 1
	else:
		EnterToTerminal2_SmallerTerminal("No ssid to add.")


	if (restart == 1):
		time.sleep(2)
	
		RestartFunction()
		print "r"


def RestartFunction():
	screen.blit(get_image('images/shuttingdown.png'),(181,175))
	pygame.display.flip()
	time.sleep(3)
	os.system("reboot")

def Thread_UpdateCoreUsageInfo():
	global core_usage_tile0
	global core_usage_tile1
	global core_usage_rpi
	while True:
		if(Current_Page != 2):
			try:
				target_rpi = open ('/var/www/html/core_usage_rpi.inc','r')
				string_rpi = target_rpi.read()
				core_usage_rpi2 = string_rpi.split(',',5)
				core_usage_rpi[0] = float(core_usage_rpi2[0])
				core_usage_rpi[1] = float(core_usage_rpi2[1])
				core_usage_rpi[2] = float(core_usage_rpi2[2])
				core_usage_rpi[3] = float(core_usage_rpi2[3])
				target_rpi.close()
		
				target_xmos = open('/var/www/html/core_usage_xmos.inc','r')
				string_xmos = target_xmos.read()
				core_usage_xmos = string_xmos.split(',',16)
				core_usage_tile0[0] = float(core_usage_xmos[0])
				core_usage_tile0[1] = float(core_usage_xmos[1])
				core_usage_tile0[2] = float(core_usage_xmos[2])
				core_usage_tile0[3] = float(core_usage_xmos[3])
				core_usage_tile0[4] = float(core_usage_xmos[4])
				core_usage_tile0[5] = float(core_usage_xmos[5])
				core_usage_tile0[6] = float(core_usage_xmos[6])
				core_usage_tile0[7] = float(core_usage_xmos[7])
				core_usage_tile1[0] = float(core_usage_xmos[8])
				core_usage_tile1[1] = float(core_usage_xmos[9])
				core_usage_tile1[2] = float(core_usage_xmos[10])
				core_usage_tile1[3] = float(core_usage_xmos[11])
				core_usage_tile1[4] = float(core_usage_xmos[12])
				core_usage_tile1[5] = float(core_usage_xmos[13])
				core_usage_tile1[6] = float(core_usage_xmos[14])
				core_usage_tile1[7] = float(core_usage_xmos[15])
				target_xmos.close()

				#Printing
				#print core_usage_rpi
				#print core_usage_tile0
				#print core_usage_tile1
				#print "ethernet_alive"
				
			except Exception as inst:
				print inst
		time.sleep(2)

def UpdatePercentagePage():
	global core_usage_rpi
	global core_usage_tile0
	global core_usage_tile1

	avg_rpi = (core_usage_rpi[0]+core_usage_rpi[1]+core_usage_rpi[2]+core_usage_rpi[3])/4;
	screen.blit(get_image('images/display_r3_c1_s1.png'),(0,175))  
	font = pygame.font.SysFont("Roboto Condensed", 65)
	text = font.render (str(int(avg_rpi))+"%", True, (0, 0, 0))
	screen.blit(text,(50,230))

	avg_tile0 = (core_usage_tile0[0]+core_usage_tile0[1]+core_usage_tile0[2]+core_usage_tile0[3]+core_usage_tile0[4]+core_usage_tile0[5]+core_usage_tile0[6]+core_usage_tile0[7])/8
	font = pygame.font.SysFont("Roboto Condensed", 65)
	text = font.render (str(int(avg_tile0))+"%", True, (0, 0, 0))
	screen.blit(text,(265,230))

	avg_tile1 = (core_usage_tile1[0]+core_usage_tile1[1]+core_usage_tile1[2]+core_usage_tile1[3]+core_usage_tile1[4]+core_usage_tile1[5]+core_usage_tile1[6]+core_usage_tile1[7])/8
	font = pygame.font.SysFont("Roboto Condensed", 65)
	text = font.render (str(int(avg_tile1))+"%", True, (0, 0, 0))
	screen.blit(text,(510,230))

def getYCoordFromH(inp):
	outp = 232 + 2*(100-inp)
	return outp

def FilesystemReset():
	text_file2 = open("../../logs/driving/driving_command.inc","w")
	text_file2.write("NOCHANGE")
	text_file2.close()
	text_file3 = open("/var/www/html/core_usage_xmos.inc","w")
	text_file3.write("0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0")
	text_file3.close()

def UpdateHomePage():
	global core_usage_rpi
	global core_usage_tile0
	global core_usage_tile1

	color_rpi = (185, 17, 64)
	color_tile0 = (0, 153, 204)
	color_tile1 = (255, 153, 0)

	bars_w = 28
	mult_factor = 2

	coords_x_rpi = [64, 95, 127, 158]
	coords_x_tile0 = [205, 236, 268, 299, 330, 361, 392, 423]
	coords_x_tile1 = [464, 495, 527, 558, 589, 620, 651, 682]

	#y coord calculation 232 + 2*(100-h)
	screen.blit(get_image('images/coresimg.png'),(0,175))   

	for i in range (0,4):
		y_coord = getYCoordFromH(core_usage_rpi[i])
		pygame.draw.rect(screen, color_rpi, pygame.Rect(coords_x_rpi[i], y_coord, 28, 2*core_usage_rpi[i]))
		
	for i in range (0,8):
		y_coord = getYCoordFromH(core_usage_tile0[i])
		pygame.draw.rect(screen, color_tile0, pygame.Rect(coords_x_tile0[i], y_coord, 28, 2*core_usage_tile0[i]))
		
	for i in range (0,8):
		y_coord = getYCoordFromH(core_usage_tile1[i])
		pygame.draw.rect(screen, color_tile1, pygame.Rect(coords_x_tile1[i], y_coord, 28, 2*core_usage_tile1[i]))
		
	avg_rpi = (core_usage_rpi[0]+core_usage_rpi[1]+core_usage_rpi[2]+core_usage_rpi[3])/4; 
	font = pygame.font.SysFont("Roboto Condensed", 25)
	text = font.render ("Avg : "+str(int(avg_rpi))+"%", True, (100, 100, 100))
	screen.blit(text,(60,180))

	avg_tile0 = (core_usage_tile0[0]+core_usage_tile0[1]+core_usage_tile0[2]+core_usage_tile0[3]+core_usage_tile0[4]+core_usage_tile0[5]+core_usage_tile0[6]+core_usage_tile0[7])/8
	font = pygame.font.SysFont("Roboto Condensed", 25)
	text = font.render ("Avg : "+str(int(avg_tile0))+"%", True, (100, 100, 100))
	screen.blit(text,(275,180))

	avg_tile1 = (core_usage_tile1[0]+core_usage_tile1[1]+core_usage_tile1[2]+core_usage_tile1[3]+core_usage_tile1[4]+core_usage_tile1[5]+core_usage_tile1[6]+core_usage_tile1[7])/8
	font = pygame.font.SysFont("Roboto Condensed", 25)
	text = font.render ("Avg : "+str(int(avg_tile1))+"%", True, (100, 100, 100))
	screen.blit(text,(520,180))
	
	
#Main

cmdargs = len ( sys.argv )

if (cmdargs>3): #Fullscreen
	fullscreenmode = 1
else:
	fullscreenmode = 0

#Filesystem buffer files reset, init.py
FilesystemReset()

#Pygame display init
pygame.init()
if (fullscreenmode == 0):
	screen = pygame.display.set_mode((800, 480))#,pygame.FULLSCREEN)
else:
	screen = pygame.display.set_mode((800, 480),pygame.FULLSCREEN)
pygame.display.set_caption("APP4MC RCCAR Display")
surface = pygame.Surface((800, 480), pygame.SRCALPHA)
clock = pygame.time.Clock()

done = False

#Load images
_image_library = {}

#Network
GetMyProcessID()

current_static_ip = GetMyIPAddress('eth0')
previous_static_ip = current_static_ip
print "My Static IP Address : " + previous_static_ip

current_gateway = GetMyGateway()
previous_gateway = current_gateway
print "My Gateway : " + previous_gateway

prev_psk = GetMyPSK()
prev_ssid = GetMySSID()
current_psk = prev_psk
current_ssid = prev_ssid
print "My SSID : " + prev_ssid
print "My PSK : " + prev_psk

#Background
screen.fill((255, 255, 255))
screen.blit(get_image('images/displayintro.png'),(0,0))
pygame.display.flip()
time.sleep(2)

Current_Page = 1
New_Current_Page = 1
HomePage()

#Thread start
threading.Thread(target=Thread_UpdateCoreUsageInfo).start()

while not done:
	#Events
	for event in pygame.event.get():
		if event.type == pygame.QUIT:
			done = True
			s.close()
		if event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
			done = True
			s.close()
		if event.type == pygame.MOUSEBUTTONDOWN:
			(mouseX, mouseY) = pygame.mouse.get_pos()
			#Control screen state using mouseclick coordinates
			if ((mouseX>710 and mouseX<710+90) and (mouseY>0 and mouseY < 0+94)):
				New_Current_Page = 2
			elif ((mouseX>710 and mouseX<710+90) and (mouseY>94 and mouseY < 94+93)):
				QuitFunction()
			elif ((mouseX>710 and mouseX<710+90) and (mouseY>187 and mouseY < 187+107)):
				ShutdownSystem()
			elif ((mouseX>710 and mouseX<710+90) and (mouseY>294 and mouseY < 294+84)):
				#Previous_Page
				if (Current_Page == 1):
					New_Current_Page = 8
				elif (Current_Page == 8):
					New_Current_Page = 7
				elif (Current_Page == 7):
					New_Current_Page = 5
				elif (Current_Page == 5):
					New_Current_Page = 4
				elif (Current_Page == 4):
					New_Current_Page = 3
				elif (Current_Page == 3):
					New_Current_Page = 1
				else:
					New_Current_Page = 1
			
			elif ((mouseX>710 and mouseX<710+90) and (mouseY>378 and mouseY < 378+102)):
				#Next_Page
				if (Current_Page == 1): #Homepage
					New_Current_Page = 3
				elif (Current_Page == 3):
					New_Current_Page = 4
				elif (Current_Page == 4):
					New_Current_Page = 5
				elif (Current_Page == 5):
					New_Current_Page = 7#6
				elif (Current_Page == 6):
					New_Current_Page = 7
				elif (Current_Page == 7):
					New_Current_Page = 8
				else:
					New_Current_Page = 1

			if (Current_Page == 2): #Settings Page
				if ((mouseX>220 and mouseX<220+250) and (mouseY>120 and mouseY < 120+40)):
					#Static IP Prompt
					current_static_ip = mykeys.run(screen, current_static_ip)
					UpdateSettingsPageValues()
				elif ((mouseX>220 and mouseX<220+250) and (mouseY>170 and mouseY < 170+40)):
					#Gateway Prompt
					current_gateway = mykeys.run(screen, current_gateway)
					UpdateSettingsPageValues()
				elif ((mouseX>220 and mouseX<220+250) and (mouseY>220 and mouseY < 220+40)):
					#SSID Prompt
					current_ssid = mykeys.run(screen, current_ssid)
					UpdateSettingsPageValues()
				elif ((mouseX>220 and mouseX<220+250) and (mouseY>270 and mouseY < 270+40)):
					#PSK Prompt
					current_psk = mykeys.run(screen, current_psk)
					UpdateSettingsPageValues()
				elif ((mouseX>243 and mouseX<243+227) and (mouseY>330 and mouseY<330+49)):
					#Enter button
					Settings_NetworkSettingsOfDevice()
			
			if (Current_Page == 4): #AllocationPage
				start_w = 60
				kill_w = 50
				h=40
				
				for i in range(0,aprocess_list_len):
					if ((mouseX>180+coord_x[i] and mouseX<180+coord_x[i]+start_w) and (mouseY>coord_y[i] and mouseY < coord_y[i]+h)):
						StartProcess(aprocess_list[i].apname)
					if ((mouseX>250+coord_x[i] and mouseX<250+coord_x[i]+kill_w) and (mouseY>coord_y[i] and mouseY < coord_y[i]+h)):
						KillProcess(aprocess_list[i].apname)

			if (Current_Page == 5 ):
				#CoreAllocationPage
				start_w = 60
				kill_w = 80
				h=40

				for i in range(0,aprocess_list_len):
					if ((mouseX>250+coord_x[i] and mouseX<250+coord_x[i]+kill_w) and (mouseY>coord_y[i] and mouseY < coord_y[i]+h)):
						AllocateProcess(aprocess_list[i].apname)

			if (New_Current_Page == 7): #ChangeDistributionPage
				if ((mouseX>220 and mouseX<220+350) and (mouseY>280 and mouseY<280+40)):
					#Automatic (OS) distro
					distribution_type=2
					AutomaticDistributionActions()
				elif ((mouseX>220 and mouseX<220+350) and (mouseY>340 and mouseY<340+40)):
					#APP4MC distro
					distribution_type=1
					APP4MCDistributionActions()
				elif ((mouseX>220 and mouseX<220+350) and (mouseY>220 and mouseY<220+40)):
					#sequential distro
					distribution_type=3
					SequentialDistributionActions()

	if (Current_Page == 3):
		UpdatePercentagePage()
	elif (Current_Page == 1):
		UpdateHomePage()
	elif (Current_Page == 6):
		UpdateHomePage()
		font = pygame.font.SysFont("Roboto Condensed", 65)
		text = font.render ("Deadline Miss!", True, (255, 0, 0))
		screen.blit(text,(170,170))
	elif (Current_Page == 4 ):
		try:
			UpdateAllocationPage()
		except Exception as inst:
			print inst
	elif (Current_Page == 5 ):
		try:
			UpdateCoreAllocationPage()
		except Exception as inst:
			print inst
	elif (Current_Page == 7):
		try:
			UpdateChangeDistributionPage()
		except Exception as inst:
			print inst
	elif (Current_Page == 8):
		try:
			UpdateShowDistributionPage()
		except Exception as inst:
			print inst

	#Page Updates
	if (New_Current_Page != Current_Page):
		if (New_Current_Page == 1):
			HomePage()
			
		elif (New_Current_Page == 2):
			SettingsPage()
			
		elif (New_Current_Page == 3):
			PercentagePage()

		elif (New_Current_Page == 4):
			AllocationPage()

		elif (New_Current_Page == 5):
			CoreAllocationPage()

		elif (New_Current_Page == 6):
			DeadlineMissPage()

		elif (New_Current_Page == 7):
			ChangeDistributionPage()

		elif (New_Current_Page == 8):
			ShowDistributionPage()
			
		Current_Page = New_Current_Page

	pygame.display.flip()

	if (_PERIOD > _EXECUTION_TIME):
		time.sleep(_PERIOD - _EXECUTION_TIME)#(0.1)
	clock.tick(60)
