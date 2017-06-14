#!/usr/bin/env python

# Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Description:
#    A4MCAR Project - "aprocess" is a class that defines A4MCAR high-level module
#					  process attributes and functions.
#					  This class also implements process management functions.
#
# Author:
#    M. Ozcelikors <mozcelikors@gmail.com>

import subprocess
import os
import ctypes

libc = ctypes.cdll.LoadLibrary('libc.so.6')
SYS_gettid = 224 #For Raspbian Jessie arm-linux, Look from /usr/include/arm-linux-gnueabihf/asm/unistd.h

class aprocess:

	def __init__ (self, apname, traceable, aplogfilepath, displayed, display_name, apstartcommand, isthread):

		#Basic Attributes for Process
		self.apname = apname #Process Name, Must be the similar to ps command
		self.apid   = 0 #Process ID (PID), 0 means the process is not running
		self.aprunning = 0 #Flag that restores if a process is running
		self.aaffinity = "0-3" #Core Affinity for the process, must be string
		self.apstartcommand = apstartcommand #Command to start process
		self.isthread = isthread #Flag to indicate whether the process is actually a thread
		
		#Tracing Related Attributes
		self.traceable = traceable # Only traceable processes are considered in timing calculations.
		self.aplogfilepath = aplogfilepath #Where the timing log file for this process located, for traceable processes, must be string

		#Display Related Attributes
		self.displayed = displayed
		self.display_name = display_name
		
		self.UpdateProcessIDAndRunning()
		self.UpdateProcessCoreAffinity()
		
		
	def UpdateProcessIDAndRunning(self):
		if (self.isthread == 0):
			# Returns process id, or 0 if process not running
			try:
				self.aprunning = 1
				x = subprocess.check_output(['pgrep','-f',self.apname,'-n']) #,'-u','root'
			except Exception as inst:
				x = 0
				self.aprunning = 0
			self.apid = x
		return 1
		
	def UpdateProcessCoreAffinity(self):
		#Returns which core the process is running on
		cmd = ['taskset','-c','-p', str(self.apid) .strip('\n')]
		try:
			x = subprocess.check_output(cmd, shell=False, stderr=subprocess.STDOUT)
			affinity_list = x.split(':')[1].strip('\n')
		except Exception as inst:
			#print inst
			affinity_list = "NaN"
		self.aaffinity = affinity_list
		
	def SetCoreAffinity (self, core_affinity):
		#Sets core affinity of a process object using taskset
		if (self.aprunning == 1 and core_affinity != ""):
			try:
				os.system("sudo taskset -pc "+str(core_affinity)+" "+str(self.apid))
				self.UpdateProcessCoreAffinity()
			except Exception as inst:
				#print inst
				#print "Err-SetCoreAffinity"
				debug = 1

	def UpdateThreadIDAndRunning(self):
		if (self.isthread == 1):
			self.apid = libc.syscall(SYS_gettid)
			if (self.apid != -1):
				self.aprunning = 1
			else:
				self.aprunning = 0
			#print self.apid
		return 1

	def SetCoreAffinityOfThread(self, core_affinity):
		if (self.isthread == 1):
			if (self.aprunning == 1 and core_affinity != ""):
				try:
					os.system("sudo taskset -pc "+str(core_affinity)+" "+str(self.apid))
					self.UpdateProcessCoreAffinity()
				except Exception as inst:
					debug = 1
					print inst
		