#!/bin/bash

# This bash script can be used to start touchscreen display application 
# using secondary display (vncviewer's display)
 
cd /home/pi/a4mcar/high_level_applications/apps/touchscreen_display
sudo python touchscreen_display.py -display :1.0