#!/bin/bash
A0=7
A1=8
A2=25
A3=24
A4=23

gpio -g mode $A0 out
gpio -g mode $A1 out
gpio -g mode $A2 out
gpio -g mode $A3 out
gpio -g mode $A4 out

gpio -g write $A0 1
gpio -g write $A1 0
gpio -g write $A2 1
gpio -g write $A3 1
gpio -g write $A4 1

sleep 0.1

gpio -g write $A0 0
gpio -g write $A1 1
gpio -g write $A2 1
gpio -g write $A3 1
gpio -g write $A4 1