#!/usr/bin/env python

# Author: mozcelikors

import pygame
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

mykeys = virtkeyboard.VirtualKeyboard()
mykeyboard_inputtext=""

current_static_ip = ""
current_gateway = ""
current_ssid = ""
current_psk = ""
prev_psk = ""
prev_ssid = ""
previous_gateway = ""
previous_static_ip = ""
core_usage_tile0 = [0,0,0,0,0,0,0,0]
core_usage_tile1 = [0,0,0,0,0,0,0,0]
core_usage_rpi= [0,0,0,0]

Xtightvnc =0
mjpg_streamer =0
display =0
ethernet_app_rpi =0
record_core_usage_rpi =0
burn_cycles_around25_1 =0
burn_cycles_around25_2 =0
burn_cycles_around25_3 =0
burn_cycles_around25_4 =0
burn_cycles_around25_5 =0
burn_cycles_around100 =0
apache2 =0
avoidobjects_raspicam = 0

Xtightvnc_core="0-3"
mjpg_streamer_core="0-3"
display_core="0-3"
ethernet_app_rpi_core="0-3"
record_core_usage_rpi_core="0-3"
burn_cycles_around25_1_core="0-3"
burn_cycles_around25_2_core="0-3"
burn_cycles_around25_3_core="0-3"
burn_cycles_around25_4_core="0-3"
burn_cycles_around25_5_core="0-3"
burn_cycles_around100_core="0-3"
apache2_core="0-3"
avoidobjects_raspicam_core = "0-3"

distribution_type=2
current_thyme = 0
previous_thyme = 0

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
	global prev_psk
	global prev_ssid
	global previous_gateway
	global previous_static_ip

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
		print inst
		affinity_list = "NaN"
	#try:
	#	processpid = int(str(pid).strip('\n'))
	#	p = psutil.Process(processpid)
	#	x = p.cpu_affinity()
	#except Exception as inst:
	#	print inst
	#	x = "NaN"
	return affinity_list

def UpdateProcessInfo():
	global Xtightvnc
	global mjpg_streamer
	global display
	global ethernet_app_rpi
	global record_core_usage_rpi
	global burn_cycles_around25_1
	global burn_cycles_around25_2
	global burn_cycles_around25_3
	global burn_cycles_around25_4
	global burn_cycles_around25_5
	global burn_cycles_around100
	global apache2
        global avoidobjects_raspicam
	try:
		Xtightvnc = CheckIfProcessRunning("Xtightvnc")	
		mjpg_streamer = CheckIfProcessRunning("mjpg_streamer")
		display = CheckIfProcessRunning("display")
		ethernet_app_rpi = CheckIfProcessRunning("ethernet_app_rpi")
		record_core_usage_rpi = CheckIfProcessRunning("record_core_usage_rpi")
		burn_cycles_around25_1 = CheckIfProcessRunning("burn_cycles_around25_1")
		burn_cycles_around25_2 = CheckIfProcessRunning("burn_cycles_around25_2")
		burn_cycles_around25_3 = CheckIfProcessRunning("burn_cycles_around25_3")
		burn_cycles_around25_4 = CheckIfProcessRunning("burn_cycles_around25_4")
		burn_cycles_around25_5 = CheckIfProcessRunning("burn_cycles_around25_5")
		burn_cycles_around100 = CheckIfProcessRunning("burn_cycles_around100")
		apache2 = CheckIfProcessRunning("apache2")
                avoidobjects_raspicam = CheckIfProcessRunning("AvoidObjects_Raspicam")
	except Exception as inst:
		print inst


def ChangeDistributionPage():
	Clear_Variables()
	
	print "ChangeDistributionPage"
	screen.blit(get_image('images/settingsypm_r1_c1_s1.png'),(0,0))    
	screen.blit(get_image('images/display_r3_c1_s1.png'),(0,175))    
	screen.blit(get_image('images/display_r1_c2_s1.png'),(710,0))    
	screen.blit(get_image('images/display_r2_c2_s1.png'),(710,94))
	screen.blit(get_image('images/display_r4_c2_s1.png'),(710,184)) 
	screen.blit(get_image('images/display_r5_c2_s1.png'),(710,294))
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
	global distribution_type
	global previous_thyme
	global current_thyme

	#0.072 our deadline
	deadline = 0.08#0.072
	
	font = pygame.font.SysFont("Roboto Condensed", 40)
	text = font.render ("Deadline Miss:", True, (0, 0, 255))
	screen.blit(text,(240,120))

	screen.blit(get_image('images/display_r3_c1_s1.png'),(0,175)) 

	current_thyme = time.clock()
	difference = current_thyme - previous_thyme
	#print difference

	font = pygame.font.SysFont("Roboto Condensed", 20)
	text = font.render ("Response: "+str(difference), True, (0,0,0))
	screen.blit(text,(500,190))

	percentage_val = int((difference-deadline)/difference*100)
	#print percentage_val
	previous_thyme = current_thyme

	font = pygame.font.SysFont("Roboto Condensed", 100)
	if (difference>deadline):
		 
		text = font.render (str(percentage_val)+"%", True, (0, 0, 0))
		screen.blit(text,(300,200))
		pygame.display.flip()
	else:
		text = font.render ("0%", True, (0, 0, 0))
		screen.blit(text,(300,200))
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
	
	

def AutomaticDistributionActions():
	global Xtightvnc
	global mjpg_streamer
	global display
	global ethernet_app_rpi
	global record_core_usage_rpi
	global burn_cycles_around25_1
	global burn_cycles_around25_2
	global burn_cycles_around25_3
	global burn_cycles_around25_4
	global burn_cycles_around25_5
	global burn_cycles_around100
	global apache2
	global avoidobjects_raspicam

	UpdateProcessInfo()
	
	try:
		os.system("sudo taskset -pc "+"0-3"+" "+Xtightvnc)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0-3"+" "+mjpg_streamer)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0-3"+" "+display)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0-3"+" "+ethernet_app_rpi)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0-3"+" "+record_core_usage_rpi)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0-3"+" "+burn_cycles_around25_1)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0-3"+" "+burn_cycles_around25_2)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0-3"+" "+burn_cycles_around25_3)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0-3"+" "+burn_cycles_around25_4)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0-3"+" "+burn_cycles_around25_5)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0-3"+" "+burn_cycles_around100)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0-3"+" "+apache2)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0-3"+" "+avoidobjects_raspicam)
	except:
		a=1
	

def APP4MCDistributionActions():
	global Xtightvnc
	global mjpg_streamer
	global display
	global ethernet_app_rpi
	global record_core_usage_rpi
	global burn_cycles_around25_1
	global burn_cycles_around25_2
	global burn_cycles_around25_3
	global burn_cycles_around25_4
	global burn_cycles_around25_5
	global burn_cycles_around100
	global apache2
        global avoidobjects_raspicam
        
	UpdateProcessInfo()
	
	try:
		os.system("sudo taskset -pc "+"1"+" "+Xtightvnc)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0"+" "+mjpg_streamer)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"1"+" "+display)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"1"+" "+ethernet_app_rpi)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0"+" "+record_core_usage_rpi)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0"+" "+burn_cycles_around25_1)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"2"+" "+burn_cycles_around25_2)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"2"+" "+burn_cycles_around25_3)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"0"+" "+burn_cycles_around25_4)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"3"+" "+burn_cycles_around25_5)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"3"+" "+burn_cycles_around100)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"1"+" "+apache2)
	except:
		a=1

	try:
		os.system("sudo taskset -pc "+"2"+" "+avoidobjects_raspicam)
	except:
		a=1
                


def SequentialDistributionActions():
	global Xtightvnc
	global mjpg_streamer
	global display
	global ethernet_app_rpi
	global record_core_usage_rpi
	global burn_cycles_around25_1
	global burn_cycles_around25_2
	global burn_cycles_around25_3
	global burn_cycles_around25_4
	global burn_cycles_around25_5
	global burn_cycles_around100
	global apache2
        global avoidobjects_raspicam
        
	UpdateProcessInfo()
	
	try:
		os.system("sudo taskset -pc "+"3"+" "+Xtightvnc)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"3"+" "+mjpg_streamer)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"3"+" "+display)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"3"+" "+ethernet_app_rpi)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"3"+" "+record_core_usage_rpi)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"3"+" "+burn_cycles_around25_1)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"3"+" "+burn_cycles_around25_2)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"3"+" "+burn_cycles_around25_3)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"3"+" "+burn_cycles_around25_4)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"3"+" "+burn_cycles_around25_5)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"3"+" "+burn_cycles_around100)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"3"+" "+apache2)
	except:
		a=1
	try:
		os.system("sudo taskset -pc "+"3"+" "+avoidobjects_raspicam)
	except:
		a=1


def ShowDistributionPage():
	
	Clear_Variables()
	
	print "ShowDistributionPage"
	screen.blit(get_image('images/settingsypm_r1_c1_s1.png'),(0,0))    
	screen.blit(get_image('images/display_r3_c1_s1.png'),(0,175))    
	screen.blit(get_image('images/display_r1_c2_s1.png'),(710,0))    
	screen.blit(get_image('images/display_r2_c2_s1.png'),(710,94))
	screen.blit(get_image('images/display_r4_c2_s1.png'),(710,184)) 
	screen.blit(get_image('images/display_r5_c2_s1.png'),(710,294))
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Show Timing Performance", True, (255, 255, 255))
	screen.blit(text,(30,30))

	UpdateShowDistributionPage()

	
	

	return 1

def UpdateAllocationPage():
	global Xtightvnc
	global mjpg_streamer
	global display
	global ethernet_app_rpi
	global record_core_usage_rpi
	global burn_cycles_around25_1
	global burn_cycles_around25_2
	global burn_cycles_around25_3
	global burn_cycles_around25_4
	global burn_cycles_around25_5
	global burn_cycles_around100
	global apache2
        global avoidobjects_raspicam

	UpdateProcessInfo()

	x=100
	if (mjpg_streamer!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Camera Stream", True, colorc)
	screen.blit(text,(30,120))
	y=50
	if (Xtightvnc!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	text = font.render ("VNC Server", True, colorc)
	screen.blit(text,(30,120+y))
	y=100
	if (ethernet_app_rpi!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	text = font.render ("Ethernet App", True, colorc)
	screen.blit(text,(30,120+y))
	y=150
	if (apache2!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	text = font.render ("Apache Server", True, colorc)
	screen.blit(text,(30,120+y))
	y=200
	if (record_core_usage_rpi!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	text = font.render ("Core Recorder", True, colorc)
	screen.blit(text,(30,120+y))
	y=250
	if (display!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	text = font.render ("Display", True, colorc)
	screen.blit(text,(30,120+y))
	y=300
	if (burn_cycles_around25_1!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	text = font.render ("Cycler25_1", True, colorc)
	screen.blit(text,(30,120+y))
	xx=350
	if (burn_cycles_around25_2!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	text = font.render ("Cycler25_2", True, colorc)
	screen.blit(text,(30+xx,120))
	y=50
	if (burn_cycles_around25_3!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	text = font.render ("Cycler25_3", True, colorc)
	screen.blit(text,(30+xx,120+y))
	y=100
	if (burn_cycles_around100!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	text = font.render ("Cycler100", True, colorc)
	screen.blit(text,(30+xx,120+y))
	y=150
	if (burn_cycles_around25_4!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	text = font.render ("Cycler25_4", True, colorc)
	screen.blit(text,(30+xx,120+y))
	y=200
	if (burn_cycles_around25_5!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	text = font.render ("Cycler25_5", True, colorc)
	screen.blit(text,(30+xx,120+y))
        y=250
	if (avoidobjects_raspicam!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	text = font.render ("ImageProcess", True, colorc)
	screen.blit(text,(30+xx,120+y))


def KillProcess(process_name):
	global Xtightvnc
	global mjpg_streamer
	global display
	global ethernet_app_rpi
	global record_core_usage_rpi
	global burn_cycles_around25_1
	global burn_cycles_around25_2
	global burn_cycles_around25_3
	global burn_cycles_around25_4
	global burn_cycles_around25_5
	global burn_cycles_around100
	global apache2
        global avoidobjects_raspicam

	if (process_name == "mjpg_streamer"):
		pid = mjpg_streamer
	elif(process_name == "Xtightvnc"):
		pid =Xtightvnc
	elif (process_name == "ethernet_app_rpi"):
		pid = ethernet_app_rpi
	elif (process_name == "display"):
		pid = display
	elif (process_name =="record_core_usage_rpi"):
		pid = record_core_usage_rpi
	elif (process_name == "burn_cycles_around25_1"):
		pid = burn_cycles_around25_1
	elif (process_name == "burn_cycles_around25_2"):
		pid = burn_cycles_around25_2
	elif (process_name == "burn_cycles_around25_3"):
		pid = burn_cycles_around25_3
	elif (process_name == "burn_cycles_around25_4"):
		pid = burn_cycles_around25_4
	elif (process_name == "burn_cycles_around25_5"):
		pid = burn_cycles_around25_5
	elif (process_name == "burn_cycles_around100"):
		pid = burn_cycles_around100
	elif (process_name == "apache2"):
		pid = apache2
        elif (process_name == "AvoidObjects_Raspicam"):
                pid = avoidobjects_raspicam
	else:
		pid=""

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

def AllocateProcess(process_name):
	global Xtightvnc
	global mjpg_streamer
	global display
	global ethernet_app_rpi
	global record_core_usage_rpi
	global burn_cycles_around25_1
	global burn_cycles_around25_2
	global burn_cycles_around25_3
	global burn_cycles_around25_4
	global burn_cycles_around25_5
	global burn_cycles_around100
	global apache2
        global avoidobjects_raspicam
	global Xtightvnc_core
	global mjpg_streamer_core
	global display_core
	global ethernet_app_rpi_core
	global record_core_usage_rpi_core
	global burn_cycles_around25_1_core
	global burn_cycles_around25_2_core
	global burn_cycles_around25_3_core
	global burn_cycles_around25_4_core
	global burn_cycles_around25_5_core
	global burn_cycles_around100_core
	global apache2_core
        global avoidobjects_raspicam_core

	if (process_name == "mjpg_streamer"):
		pid = mjpg_streamer
		core = mykeys.run(screen, mjpg_streamer_core)
	elif(process_name == "Xtightvnc"):
		pid =Xtightvnc
		core = mykeys.run(screen, Xtightvnc_core)
	elif (process_name == "ethernet_app_rpi"):
		pid = ethernet_app_rpi
		core = mykeys.run(screen, ethernet_app_rpi_core)
	elif (process_name == "display"):
		pid = display
		core = mykeys.run(screen, display_core)
	elif (process_name =="record_core_usage_rpi"):
		pid = record_core_usage_rpi
		core = mykeys.run(screen, record_core_usage_rpi_core)
	elif (process_name == "burn_cycles_around25_1"):
		pid = burn_cycles_around25_1
		core = mykeys.run(screen, burn_cycles_around25_1_core)
	elif (process_name == "burn_cycles_around25_2"):
		pid = burn_cycles_around25_2
		core = mykeys.run(screen, burn_cycles_around25_2_core)
	elif (process_name == "burn_cycles_around25_3"):
		pid = burn_cycles_around25_3
		core = mykeys.run(screen, burn_cycles_around25_3_core)
	elif (process_name == "burn_cycles_around25_4"):
		pid = burn_cycles_around25_4
		core = mykeys.run(screen, burn_cycles_around25_4_core)
	elif (process_name == "burn_cycles_around25_5"):
		pid = burn_cycles_around25_5
		core = mykeys.run(screen, burn_cycles_around25_5_core)
	elif (process_name == "burn_cycles_around100"):
		pid = burn_cycles_around100
		core = mykeys.run(screen, burn_cycles_around100_core)
	elif (process_name == "apache2"):
		pid = apache2
		core = mykeys.run(screen, apache2_core)
        elif (process_name == "AvoidObjects_Raspicam"):
                pid = avoidobjects_raspicam
                core = mykeys.run (screen, avoidobjects_raspicam_core)
	else:
		pid=""
		core=""

	try:
		os.system("sudo taskset -pc "+core+" "+pid)
	except Exception as inst:
		#print inst
		a=1


def StartProcess(process_name):
	if (process_name == "apache2"):
		os.system("sudo service apache2 start")
	elif (process_name == "record_core_usage_rpi"):
		os.system("cd /var/www/html/ && sudo python record_core_usage_rpi.py &")
	elif (process_name == "ethernet_app_rpi"):
		os.system("cd /var/www/html/ && sudo python ethernet_app_rpi.py &")
	elif (process_name == "mjpg_streamer"):
		os.system("cd /home/pi/  && sudo bash webcam_stream_start_from_rpi_camera.sh &")
	elif (process_name == "burn_cycles_around25_1"):
		os.system("cd /home/pi/process_manipulating_functions/burn_cycles && sudo python burn_cycles_around25_1.py &")
	elif (process_name == "burn_cycles_around25_2"):
		os.system("cd /home/pi/process_manipulating_functions/burn_cycles && sudo python burn_cycles_around25_2.py &")
	elif (process_name == "burn_cycles_around25_3"):
		os.system("cd /home/pi/process_manipulating_functions/burn_cycles && sudo python burn_cycles_around25_3.py &")
	elif (process_name == "burn_cycles_around25_4"):
		os.system("cd /home/pi/process_manipulating_functions/burn_cycles && sudo python burn_cycles_around25_4.py &")
	elif (process_name == "burn_cycles_around25_5"):
		os.system("cd /home/pi/process_manipulating_functions/burn_cycles && sudo python burn_cycles_around25_5.py &")
	elif (process_name == "burn_cycles_around100"):
		os.system("cd /home/pi/process_manipulating_functions/burn_cycles && sudo python burn_cycles_around100.py &")
        elif (process_name == "AvoidObjects_Raspicam"):
                os.system("cd /home/pi/opencv_workspace/TrafficConeDetection && sudo -E ./AvoidObjects_Raspicam &")

        # & at the end in commands is important to run the app in the background
	

def AllocationPage():
	Clear_Variables()
	
	print "AllocationPage"
	screen.blit(get_image('images/settingsypm_r1_c1_s1.png'),(0,0))    
	screen.blit(get_image('images/display_r3_c1_s1.png'),(0,175))    
	screen.blit(get_image('images/display_r1_c2_s1.png'),(710,0))    
	screen.blit(get_image('images/display_r2_c2_s1.png'),(710,94))
	screen.blit(get_image('images/display_r4_c2_s1.png'),(710,184)) 
	screen.blit(get_image('images/display_r5_c2_s1.png'),(710,294))
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Start/Kill Rpi Processes", True, (255, 255, 255))
	screen.blit(text,(30,30))

	x=100
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Camera Stream", True, (0, 0, 0))
	screen.blit(text,(30,120))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120, 60, 40)
	text = font.render ("Start", True, (255, 0, 0))
	screen.blit(text,(320-x,130))
	AddPromptBox_Passive(380-x, 120, 50, 40)
	text = font.render ("Kill", True, (255, 0, 0))
	screen.blit(text,(390-x,130))
	
	y=50
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("VNC Server", True, (0, 0, 0))
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render ("Start", True, (255, 0, 0))
	screen.blit(text,(320-x,130+y))
	AddPromptBox_Passive(380-x, 120+y, 50, 40)
	text = font.render ("Kill", True, (255, 0, 0))
	screen.blit(text,(390-x,130+y))

	y=100
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Ethernet App", True, (0, 0, 0))
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render ("Start", True, (255, 0, 0))
	screen.blit(text,(320-x,130+y))
	AddPromptBox_Passive(380-x, 120+y, 50, 40)
	text = font.render ("Kill", True, (255, 0, 0))
	screen.blit(text,(390-x,130+y))

	y=150
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Apache Server", True, (0, 0, 0))
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render ("Start", True, (255, 0, 0))
	screen.blit(text,(320-x,130+y))
	AddPromptBox_Passive(380-x, 120+y, 50, 40)
	text = font.render ("Kill", True, (255, 0, 0))
	screen.blit(text,(390-x,130+y))

	y=200
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Core Recorder", True, (0, 0, 0))
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render ("Start", True, (255, 0, 0))
	screen.blit(text,(320-x,130+y))
	AddPromptBox_Passive(380-x, 120+y, 50, 40)
	text = font.render ("Kill", True, (255, 0, 0))
	screen.blit(text,(390-x,130+y))

	y=250
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Display", True, (0, 0, 0))
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render ("Start", True, (255, 0, 0))
	screen.blit(text,(320-x,130+y))
	AddPromptBox_Passive(380-x, 120+y, 50, 40)
	text = font.render ("Kill", True, (255, 0, 0))
	screen.blit(text,(390-x,130+y))

	y=300
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_1", True, (0, 0, 0))
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render ("Start", True, (255, 0, 0))
	screen.blit(text,(320-x,130+y))
	AddPromptBox_Passive(380-x, 120+y, 50, 40)
	text = font.render ("Kill", True, (255, 0, 0))
	screen.blit(text,(390-x,130+y))
	
	xx=350
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_2", True, (0, 0, 0))
	screen.blit(text,(30+xx,120))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120, 60, 40)
	text = font.render ("Start", True, (255, 0, 0))
	screen.blit(text,(xx+320-x,130))
	AddPromptBox_Passive(xx+380-x, 120, 50, 40)
	text = font.render ("Kill", True, (255, 0, 0))
	screen.blit(text,(xx+390-x,130))

	y=50
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_3", True, (0, 0, 0))
	screen.blit(text,(30+xx,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render ("Start", True, (255, 0, 0))
	screen.blit(text,(xx+320-x,130+y))
	AddPromptBox_Passive(xx+380-x, 120+y, 50, 40)
	text = font.render ("Kill", True, (255, 0, 0))
	screen.blit(text,(xx+390-x,130+y))

	y=100
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler100", True, (0, 0, 0))
	screen.blit(text,(30+xx,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render ("Start", True, (255, 0, 0))
	screen.blit(text,(xx+320-x,130+y))
	AddPromptBox_Passive(xx+380-x, 120+y, 50, 40)
	text = font.render ("Kill", True, (255, 0, 0))
	screen.blit(text,(xx+390-x,130+y))

	y=150
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_4", True, (0, 0, 0))
	screen.blit(text,(30+xx,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render ("Start", True, (255, 0, 0))
	screen.blit(text,(xx+320-x,130+y))
	AddPromptBox_Passive(xx+380-x, 120+y, 50, 40)
	text = font.render ("Kill", True, (255, 0, 0))
	screen.blit(text,(xx+390-x,130+y))

	y=200
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_5", True, (0, 0, 0))
	screen.blit(text,(30+xx,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render ("Start", True, (255, 0, 0))
	screen.blit(text,(xx+320-x,130+y))
	AddPromptBox_Passive(xx+380-x, 120+y, 50, 40)
	text = font.render ("Kill", True, (255, 0, 0))
	screen.blit(text,(xx+390-x,130+y))

        y=250
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("ImageProcess", True, (0, 0, 0))
	screen.blit(text,(30+xx,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render ("Start", True, (255, 0, 0))
	screen.blit(text,(xx+320-x,130+y))
	AddPromptBox_Passive(xx+380-x, 120+y, 50, 40)
	text = font.render ("Kill", True, (255, 0, 0))
	screen.blit(text,(xx+390-x,130+y))


	return 1

def GetCoreInfoRpi():
	global Xtightvnc
	global mjpg_streamer
	global display
	global ethernet_app_rpi
	global record_core_usage_rpi
	global burn_cycles_around25_1
	global burn_cycles_around25_2
	global burn_cycles_around25_3
	global burn_cycles_around25_4
	global burn_cycles_around25_5
	global burn_cycles_around100
	global apache2
        global avoidobjects_raspicam
	global Xtightvnc_core
	global mjpg_streamer_core
	global display_core
	global ethernet_app_rpi_core
	global record_core_usage_rpi_core
	global burn_cycles_around25_1_core
	global burn_cycles_around25_2_core
	global burn_cycles_around25_3_core
	global burn_cycles_around25_4_core
	global burn_cycles_around25_5_core
	global burn_cycles_around100_core
	global apache2_core
        global avoidobjects_raspicam_core

	record_core_usage_rpi_core = GetProcessCoreAffinityList(record_core_usage_rpi)
	display_core = GetProcessCoreAffinityList(display)
	mjpg_streamer_core = GetProcessCoreAffinityList(mjpg_streamer)
	Xtightvnc_core = GetProcessCoreAffinityList(Xtightvnc)
	ethernet_app_rpi_core = GetProcessCoreAffinityList(ethernet_app_rpi)
	apache2_core = GetProcessCoreAffinityList(apache2)
	burn_cycles_around100_core = GetProcessCoreAffinityList(burn_cycles_around100)
	burn_cycles_around25_1_core = GetProcessCoreAffinityList(burn_cycles_around25_1)
	burn_cycles_around25_2_core = GetProcessCoreAffinityList(burn_cycles_around25_2)
	burn_cycles_around25_3_core = GetProcessCoreAffinityList(burn_cycles_around25_3)
	burn_cycles_around25_4_core = GetProcessCoreAffinityList(burn_cycles_around25_4)
	burn_cycles_around25_5_core = GetProcessCoreAffinityList(burn_cycles_around25_5)
        avoidobjects_raspicam_core = GetProcessCoreAffinityList(avoidobjects_raspicam)

def UpdateCoreAllocationPage():
	global Xtightvnc
	global mjpg_streamer
	global display
	global ethernet_app_rpi
	global record_core_usage_rpi
	global burn_cycles_around25_1
	global burn_cycles_around25_2
	global burn_cycles_around25_3
	global burn_cycles_around25_4
	global burn_cycles_around25_5
	global burn_cycles_around100
	global apache2
        global avoidobjects_raspicam
	global Xtightvnc_core
	global mjpg_streamer_core
	global display_core
	global ethernet_app_rpi_core
	global record_core_usage_rpi_core
	global burn_cycles_around25_1_core
	global burn_cycles_around25_2_core
	global burn_cycles_around25_3_core
	global burn_cycles_around25_4_core
	global burn_cycles_around25_5_core
	global burn_cycles_around100_core
	global apache2_core
        global avoidobjects_raspicam_core

	UpdateProcessInfo()
	GetCoreInfoRpi()

	#Colored names of processes and core numbers
	x=100
	if (mjpg_streamer!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Camera Stream", True, colorc)
	screen.blit(text,(30,120))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120, 60, 40)
	text = font.render (str(mjpg_streamer_core), True, (0, 0, 0))
	screen.blit(text,(320-x,130))

	y=50
	if (Xtightvnc!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("VNC Server", True, colorc)
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render (str(Xtightvnc_core), True, (0, 0, 0))
	screen.blit(text,(320-x,130+y))

	y=100
	if (ethernet_app_rpi!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Ethernet App", True, colorc)
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render (str(ethernet_app_rpi_core), True, (0, 0, 0))
	screen.blit(text,(320-x,130+y))

	y=150
	if (apache2!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Apache Server", True, colorc)
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render (str(apache2_core), True, (0, 0, 0))
	screen.blit(text,(320-x,130+y))

	y=200
	if (record_core_usage_rpi!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Core Recorder", True, colorc)
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render (str(record_core_usage_rpi_core), True, (0, 0, 0))
	screen.blit(text,(320-x,130+y))

	y=250
	if (display!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Display", True, colorc)
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render (str(display_core), True, (0, 0, 0))
	screen.blit(text,(320-x,130+y))

	y=300
	if (burn_cycles_around25_1!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_1", True, colorc)
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render (str(burn_cycles_around25_1_core), True, (0, 0, 0))
	screen.blit(text,(320-x,130+y))

	xx=350
	if (burn_cycles_around25_2!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_2", True, colorc)
	screen.blit(text,(30+xx,120))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120, 60, 40)
	text = font.render (str(burn_cycles_around25_2_core), True, (0, 0, 0))
	screen.blit(text,(xx+320-x,130))

	y=50
	if (burn_cycles_around25_3!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_3", True, colorc)
	screen.blit(text,(30+xx,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render (str(burn_cycles_around25_3_core), True, (0, 0, 0))
	screen.blit(text,(xx+320-x,130+y))

	y=100
	if (burn_cycles_around100!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler100", True, colorc)
	screen.blit(text,(30+xx,120+y))
	
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render (str(burn_cycles_around100_core), True, (0, 0, 0))
	screen.blit(text,(xx+320-x,130+y))

	y=150
	if (burn_cycles_around25_4!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_4", True, colorc)
	screen.blit(text,(30+xx,120+y))
	
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render (str(burn_cycles_around25_4_core), True, (0, 0, 0))
	screen.blit(text,(xx+320-x,130+y))

	y=200
	if (burn_cycles_around25_5!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_5", True, colorc)
	screen.blit(text,(30+xx,120+y))
	
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render (str(burn_cycles_around25_5_core), True, (0, 0, 0))
	screen.blit(text,(xx+320-x,130+y))

        y=250
	if (avoidobjects_raspicam!=0):
		colorc = (34,139,34)
	else:
		colorc = (255,0,0)
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("ImageProcess", True, colorc)
	screen.blit(text,(30+xx,120+y))
	
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render (str(avoidobjects_raspicam_core), True, (0, 0, 0))
	screen.blit(text,(xx+320-x,130+y))

	


def CoreAllocationPage():
	Clear_Variables()
	
	print "CoreAllocationPage"
	screen.blit(get_image('images/settingsypm_r1_c1_s1.png'),(0,0))    
	screen.blit(get_image('images/display_r3_c1_s1.png'),(0,175))    
	screen.blit(get_image('images/display_r1_c2_s1.png'),(710,0))    
	screen.blit(get_image('images/display_r2_c2_s1.png'),(710,94))
	screen.blit(get_image('images/display_r4_c2_s1.png'),(710,184)) 
	screen.blit(get_image('images/display_r5_c2_s1.png'),(710,294))
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Allocate Rpi Processes", True, (255, 255, 255))
	screen.blit(text,(30,30))

	x=100
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Camera Stream", True, (0, 0, 0))
	screen.blit(text,(30,120))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120, 60, 40)
	text = font.render ("", True, (0, 0, 0))
	screen.blit(text,(320-x,130))
	AddPromptBox_Passive(380-x, 120, 80, 40)
	text = font.render ("Allocate", True, (255, 0, 0))
	screen.blit(text,(390-x,130))
	
	y=50
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("VNC Server", True, (0, 0, 0))
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render ("", True, (0, 0, 0))
	screen.blit(text,(320-x,130+y))
	AddPromptBox_Passive(380-x, 120+y, 80, 40)
	text = font.render ("Allocate", True, (255, 0, 0))
	screen.blit(text,(390-x,130+y))

	y=100
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Ethernet App", True, (0, 0, 0))
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render ("", True, (0, 0, 0))
	screen.blit(text,(320-x,130+y))
	AddPromptBox_Passive(380-x, 120+y, 80, 40)
	text = font.render ("Allocate", True, (255, 0, 0))
	screen.blit(text,(390-x,130+y))

	y=150
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Apache Server", True, (0, 0, 0))
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render ("", True, (0, 0, 0))
	screen.blit(text,(320-x,130+y))
	AddPromptBox_Passive(380-x, 120+y, 80, 40)
	text = font.render ("Allocate", True, (255, 0, 0))
	screen.blit(text,(390-x,130+y))

	y=200
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Core Recorder", True, (0, 0, 0))
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render ("", True, (0, 0, 0))
	screen.blit(text,(320-x,130+y))
	AddPromptBox_Passive(380-x, 120+y, 80, 40)
	text = font.render ("Allocate", True, (255, 0, 0))
	screen.blit(text,(390-x,130+y))

	y=250
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Display", True, (0, 0, 0))
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render ("", True, (0, 0, 0))
	screen.blit(text,(320-x,130+y))
	AddPromptBox_Passive(380-x, 120+y, 80, 40)
	text = font.render ("Allocate", True, (255, 0, 0))
	screen.blit(text,(390-x,130+y))

	y=300
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_1", True, (0, 0, 0))
	screen.blit(text,(30,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(310-x, 120+y, 60, 40)
	text = font.render ("", True, (0, 0, 0))
	screen.blit(text,(320-x,130+y))
	AddPromptBox_Passive(380-x, 120+y, 80, 40)
	text = font.render ("Allocate", True, (255, 0, 0))
	screen.blit(text,(390-x,130+y))
	
	xx=350
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_2", True, (0, 0, 0))
	screen.blit(text,(30+xx,120))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120, 60, 40)
	text = font.render ("", True, (0, 0, 0))
	screen.blit(text,(xx+320-x,130))
	AddPromptBox_Passive(xx+380-x, 120, 80, 40)
	text = font.render ("Allocate", True, (255, 0, 0))
	screen.blit(text,(xx+390-x,130))

	y=50
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_3", True, (0, 0, 0))
	screen.blit(text,(30+xx,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render ("", True, (0, 0, 0))
	screen.blit(text,(xx+320-x,130+y))
	AddPromptBox_Passive(xx+380-x, 120+y, 80, 40)
	text = font.render ("Allocate", True, (255, 0, 0))
	screen.blit(text,(xx+390-x,130+y))

	y=100
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler100", True, (0, 0, 0))
	screen.blit(text,(30+xx,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render ("", True, (0, 0, 0))
	screen.blit(text,(xx+320-x,130+y))
	AddPromptBox_Passive(xx+380-x, 120+y, 80, 40)
	text = font.render ("Allocate", True, (255, 0, 0))
	screen.blit(text,(xx+390-x,130+y))

	y=150
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_4", True, (0, 0, 0))
	screen.blit(text,(30+xx,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render ("", True, (0, 0, 0))
	screen.blit(text,(xx+320-x,130+y))
	AddPromptBox_Passive(xx+380-x, 120+y, 80, 40)
	text = font.render ("Allocate", True, (255, 0, 0))
	screen.blit(text,(xx+390-x,130+y))

	y=200
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("Cycler25_5", True, (0, 0, 0))
	screen.blit(text,(30+xx,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render ("", True, (0, 0, 0))
	screen.blit(text,(xx+320-x,130+y))
	AddPromptBox_Passive(xx+380-x, 120+y, 80, 40)
	text = font.render ("Allocate", True, (255, 0, 0))
	screen.blit(text,(xx+390-x,130+y))

        y=250
	font = pygame.font.SysFont("Roboto Condensed", 30)
	text = font.render ("ImageProcess", True, (0, 0, 0))
	screen.blit(text,(30+xx,120+y))
	font = pygame.font.SysFont("Roboto Condensed", 20)
	AddPromptBox_Passive(xx+310-x, 120+y, 60, 40)
	text = font.render ("", True, (0, 0, 0))
	screen.blit(text,(xx+320-x,130+y))
	AddPromptBox_Passive(xx+380-x, 120+y, 80, 40)
	text = font.render ("Allocate", True, (255, 0, 0))
	screen.blit(text,(xx+390-x,130+y))


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
	# First, create a file of newnetworkinterfaces.ucomm, copied from /etc/network/interfaces/
	# Then copy it to /etc/network/interfaces
	restart = 0
	if((current_static_ip!=previous_static_ip or current_gateway!=previous_gateway) and Settings_IsValidIPv4Address(current_static_ip) and Settings_IsValidIPv4Address(current_gateway)):
		try:
			target = open ('newnetworkinterfaces.ucomm','w')
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
			os.system("cp newnetworkinterfaces.ucomm /etc/network/interfaces")
		except Exception as inst:
			print inst
	
		restart = 1
	else:
		EnterToTerminal2_SmallerTerminal("IP addr or gateway")
		EnterToTerminal2_SmallerTerminal("Not valid.")

	if(prev_psk!=current_psk or prev_ssid!=current_ssid):
		
		try:
			target = open ('newwpasupplicantconf.ucomm','w')
			########
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
			os.system("cp newwpasupplicantconf.ucomm /etc/wpa_supplicant/wpa_supplicant.conf")
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
	text_file = open("/var/www/html/ethernet_command_to_xmos_history.inc","w")
	text_file.write("NOCHANGE")
	text_file.close()
	text_file2 = open("/var/www/html/ethernet_command_to_xmos.inc","w")
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
	for event in pygame.event.get():
		if event.type == pygame.QUIT:
			done = True
			s.close()
		if event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
			done = True
			s.close()
		if event.type == pygame.MOUSEBUTTONDOWN:
			(mouseX, mouseY) = pygame.mouse.get_pos()
			#Control screen state with clicked part
			if ((mouseX>710 and mouseX<710+90) and (mouseY>0 and mouseY < 0+94)):
				New_Current_Page = 2
			elif ((mouseX>710 and mouseX<710+90) and (mouseY>94 and mouseY < 94+93)):
				QuitFunction()
			elif ((mouseX>710 and mouseX<710+90) and (mouseY>187 and mouseY < 187+107)):
				ShutdownSystem()
			elif ((mouseX>710 and mouseX<710+90) and (mouseY>294 and mouseY < 294+186)):
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
				if ((mouseX>210 and mouseX<210+start_w) and (mouseY>120 and mouseY < 120+h)):
					#Cam stream start
					StartProcess("mjpg_streamer")
				if ((mouseX>280 and mouseX<280+kill_w) and (mouseY>120 and mouseY < 120+h)):
					#Cam stream kill
					KillProcess("mjpg_streamer")
				if ((mouseX>210 and mouseX<210+start_w) and (mouseY>170 and mouseY < 170+h)):
					#vnc start
					StartProcess("Xtightvnc")
				if ((mouseX>280 and mouseX<280+kill_w) and (mouseY>170 and mouseY < 170+h)):
					#vnc kill
					KillProcess("Xtightvnc")
				if ((mouseX>210 and mouseX<210+start_w) and (mouseY>220 and mouseY < 220+h)):
					#eth start
					StartProcess("ethernet_app_rpi")
				if ((mouseX>280 and mouseX<280+kill_w) and (mouseY>220 and mouseY < 220+h)):
					#eth kill
					KillProcess("ethernet_app_rpi")
				if ((mouseX>210 and mouseX<210+start_w) and (mouseY>270 and mouseY < 270+h)):
					#apache start
					StartProcess("apache2")
				if ((mouseX>280 and mouseX<280+kill_w) and (mouseY>270 and mouseY < 270+h)):
					#apache kill
					KillProcess("apache2")
				if ((mouseX>210 and mouseX<210+start_w) and (mouseY>320 and mouseY < 320+h)):
					#rec start
					StartProcess("record_core_usage_rpi")
				if ((mouseX>280 and mouseX<280+kill_w) and (mouseY>320 and mouseY < 320+h)):
					#rec kill
					KillProcess("record_core_usage_rpi")
				if ((mouseX>210 and mouseX<210+start_w) and (mouseY>370 and mouseY < 370+h)):
					#disp start
					StartProcess("display")
				if ((mouseX>280 and mouseX<280+kill_w) and (mouseY>370 and mouseY < 370+h)):
					#disp kill
					KillProcess("display")
				if ((mouseX>210 and mouseX<210+start_w) and (mouseY>420 and mouseY < 420+h)):
					#25 1 start
					StartProcess("burn_cycles_around25_1")
				if ((mouseX>280 and mouseX<280+kill_w) and (mouseY>420 and mouseY < 420+h)):
					#25 1 kill
					KillProcess("burn_cycles_around25_1")
				if ((mouseX>560 and mouseX<560+start_w) and (mouseY>120 and mouseY < 120+h)):
					#25 2 start
					StartProcess("burn_cycles_around25_2")
				if ((mouseX>630 and mouseX<630+kill_w) and (mouseY>120 and mouseY < 120+h)):
					#25 2 kill
					KillProcess("burn_cycles_around25_2")
				if ((mouseX>560 and mouseX<560+start_w) and (mouseY>170 and mouseY < 170+h)):
					#25 3 start
					StartProcess("burn_cycles_around25_3")
				if ((mouseX>630 and mouseX<630+kill_w) and (mouseY>170 and mouseY < 170+h)):
					#25 3 kill
					KillProcess("burn_cycles_around25_3")
				if ((mouseX>560 and mouseX<560+start_w) and (mouseY>220 and mouseY < 220+h)):
					#100 start
					StartProcess("burn_cycles_around100")
				if ((mouseX>630 and mouseX<630+kill_w) and (mouseY>220 and mouseY < 220+h)):
					#100 kill
					KillProcess("burn_cycles_around100")
				if ((mouseX>560 and mouseX<560+start_w) and (mouseY>270 and mouseY < 270+h)):
					#25_4 start
					StartProcess("burn_cycles_around25_4")
				if ((mouseX>630 and mouseX<630+kill_w) and (mouseY>270 and mouseY < 270+h)):
					#25_4 kill
					KillProcess("burn_cycles_around25_4")
				if ((mouseX>560 and mouseX<560+start_w) and (mouseY>320 and mouseY < 320+h)):
					#25_5 start
					StartProcess("burn_cycles_around25_5")
				if ((mouseX>630 and mouseX<630+kill_w) and (mouseY>320 and mouseY < 320+h)):
					#25_5 kill
					KillProcess("burn_cycles_around25_5")
                                
                                if ((mouseX>560 and mouseX<560+start_w) and (mouseY>370 and mouseY < 370+h)):
					#avoidobjects_raspicam start
					StartProcess("AvoidObjects_Raspicam")
				if ((mouseX>630 and mouseX<630+kill_w) and (mouseY>370 and mouseY < 370+h)):
					#avoidobjects_raspicam kill
					KillProcess("AvoidObjects_Raspicam")
                                
			if (Current_Page == 5 ):
				#CoreAllocationPage
				start_w = 60
				kill_w = 80
				h=40

				if ((mouseX>280 and mouseX<280+kill_w) and (mouseY>120 and mouseY < 120+h)):
					#Cam stream allocate
					AllocateProcess("mjpg_streamer")

				if ((mouseX>280 and mouseX<280+kill_w) and (mouseY>170 and mouseY < 170+h)):
					#vnc allocate
					AllocateProcess("Xtightvnc")

				if ((mouseX>280 and mouseX<280+kill_w) and (mouseY>220 and mouseY < 220+h)):
					#eth allocate
					AllocateProcess("ethernet_app_rpi")

				if ((mouseX>280 and mouseX<280+kill_w) and (mouseY>270 and mouseY < 270+h)):
					#apache allocate
					AllocateProcess("apache2")

				if ((mouseX>280 and mouseX<280+kill_w) and (mouseY>320 and mouseY < 320+h)):
					#rec allocate
					AllocateProcess("record_core_usage_rpi")

				if ((mouseX>280 and mouseX<280+kill_w) and (mouseY>370 and mouseY < 370+h)):
					#disp allocate
					AllocateProcess("display")

				if ((mouseX>280 and mouseX<280+kill_w) and (mouseY>420 and mouseY < 420+h)):
					#25 1 allocate
					AllocateProcess("burn_cycles_around25_1")

				if ((mouseX>630 and mouseX<630+kill_w) and (mouseY>120 and mouseY < 120+h)):
					#25 2 allocate
					AllocateProcess("burn_cycles_around25_2")

				if ((mouseX>630 and mouseX<630+kill_w) and (mouseY>170 and mouseY < 170+h)):
					#25 3 allocate
					AllocateProcess("burn_cycles_around25_3")

				if ((mouseX>630 and mouseX<630+kill_w) and (mouseY>220 and mouseY < 220+h)):
					#100 allocate
					AllocateProcess("burn_cycles_around100")

				if ((mouseX>630 and mouseX<630+kill_w) and (mouseY>270 and mouseY < 270+h)):
					#25_4 allocate
					AllocateProcess("burn_cycles_around25_4")

				if ((mouseX>630 and mouseX<630+kill_w) and (mouseY>320 and mouseY < 320+h)):
					#25_5 allocate
					AllocateProcess("burn_cycles_around25_5")

                                if ((mouseX>630 and mouseX<630+kill_w) and (mouseY>370 and mouseY < 370+h)):
					#AvoidObjects_Raspicam allocate
					AllocateProcess("AvoidObjects_Raspicam")

                               
                                        

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
		
	



	#While kismi
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

	time.sleep(0.1)
	clock.tick(60)
