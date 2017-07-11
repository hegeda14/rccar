#!/bin/bash

# This bash script can be used to start touchscreen display application using 
# primary display (touchscreen display, full screen mode)

cd /home/pi/a4mcar/high_level_applications/apps/touchscreen_display
sudo ./touchscreen_display.py -display :0.0 -mode 1