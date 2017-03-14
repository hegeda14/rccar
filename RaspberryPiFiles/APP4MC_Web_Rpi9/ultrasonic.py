#!/usr/bin/python
#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#|R|a|s|p|b|e|r|r|y|P|i|-|S|p|y|.|c|o|.|u|k|
#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#
# Measure distance using an ultrasonic module
# in a loop.
#
# -----------------------
# Import required Python libraries
# -----------------------
import time
#import urllib2, urllib
import RPi.GPIO as GPIO
import string
#from ftplib import FTP
from datetime import datetime
#import ftputil

# -----------------------
# Define some functions
# -----------------------

def measure():
  # This function measures a distance
  GPIO.output(GPIO_TRIGGER, True)
  time.sleep(0.00001)
  GPIO.output(GPIO_TRIGGER, False)
  start = time.time()

  while GPIO.input(GPIO_ECHO)==0:
    start = time.time()

  while GPIO.input(GPIO_ECHO)==1:
    stop = time.time()

  elapsed = stop-start
  distance = (elapsed * 34300)/2

  return distance

def measure_average():
  # This function takes 3 measurements and
  # returns the average.
  distance1=measure()
  time.sleep(0.1)
  distance2=measure()
  time.sleep(0.1)
  distance3=measure()
  distance = distance1 + distance2 + distance3
  distance = distance / 3
  return distance

# -----------------------
# Main Script
# -----------------------
start_time = time.time()
# Use BCM GPIO references
# instead of physical pin numbers
GPIO.setmode(GPIO.BCM)

# Define GPIO to use on Pi
GPIO_TRIGGER = 15 #23
GPIO_ECHO    = 18 #24

# Set pins as output and input
GPIO.setwarnings(False)
GPIO.setup(GPIO_TRIGGER,GPIO.OUT)  # Trigger
GPIO.setup(GPIO_ECHO,GPIO.IN)      # Echo

# Set trigger to False (Low)
GPIO.output(GPIO_TRIGGER, False)

# Wrap main content in a try block so we can
# catch the user pressing CTRL-C and run the
# GPIO cleanup function. This will also prevent
# the user seeing lots of unnecessary error
# messages.

try:
	while True:
		i=0
		while i<4:
			#temp_txt = open("temp1.txt", "w+r")
			if i==0:
				distance0 = measure_average()
				time0 = time.time() - start_time
			if i==1:
				distance1 = measure_average()
				time1 = time.time() - start_time
			if i==2:
				distance2 = measure_average()
				time2 = time.time() - start_time
			if i==3:
				distance3 = measure_average()
				time3 = time.time() - start_time
			
			#temp_txt.write(str(distance))
			#temp_txt.close()
			#print("upload started.")
			#ftp = ftputil.FTPHost("192.168.2.6", "pi", "raspberry")
			#try:
			#	ftp.chdir("//var//www")
			#	ftp.upload('temp1.txt', 'value1.txt', 'a')
			#	#ftp.remove("temp.txt")
			#finally:
			#	#ftp.quit()
			#	
			#	print("upload done.")
			i = i + 1
			time.sleep(1)
		newtext = str(distance0)+","+str(time0)+","+str(distance1)+","+str(time1)+","+str(distance2)+","+str(time2)+","+str(distance3)+","+str(time3)+","
		print newtext
		text_file = open("sensor_file.inc","w+r")
		text_file.write(newtext)	
		text_file.close()
		
		#mydata=[('distance0',str(distance0)),('time0',str(time0)),('distance1',str(distance1)),('time2',str(time2)),('distance3',str(distance3)),('time3',str(time3))]
		#path='http://192.168.2.8/sensor_file_2.php'
		#req = urllib2.Request(path,mydata)
		#req.add_header("Content-type", "application/x-www-form-urlencoded")
		time.sleep(1)

except KeyboardInterrupt:
  # User pressed CTRL-C
  # Reset GPIO settings
  GPIO.cleanup()
