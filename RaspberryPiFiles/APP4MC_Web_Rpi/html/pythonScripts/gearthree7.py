#!/usr/bin/env python
##import serial
import RPi.GPIO as GPIO
import time
##ser = serial.Serial('/dev/ttyUSB0',9600)
##ser.write(chr(ord('7')))
##time.sleep(0.1)
GPIO.setmode(GPIO.BCM)
GPIO.setup(7, GPIO.OUT) #Enable - Arduino pin A0
GPIO.setup(8, GPIO.OUT) #Arduino pin A1
GPIO.setup(23, GPIO.OUT) #Arduino pin A4
GPIO.setup(24, GPIO.OUT) #Arduino pin A3
GPIO.setup(25, GPIO.OUT) #Arduino pin A2

GPIO.output(7,True) #Enablei ac
GPIO.output(8,False)
GPIO.output(25,True)
GPIO.output(24,True)
GPIO.output(23,True)
time.sleep(0.1)
GPIO.output(7,False) #Enablei kapa
GPIO.output(8,True)
GPIO.output(25,True)
GPIO.output(24,True)
GPIO.output(23,True)
