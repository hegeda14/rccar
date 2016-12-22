#!/bin/bash

#
# Author: mozcelikors
# Usage:  Check out processes using  "top" command.
#         You can place those processes to cores by listing them below
#         bash CorePlacer.sh <process_name> <core_list>
#	  <core_list> can be 0, 1 , 2 ,3 , 0-1, 1-2, 0-2, 0-3, 1-3
#
# ATTENTION: DO NOT RUN THIS SCRIPT AS ROOT.. NO SUDO

cd /home/pi/process_manipulating_functions/process_functions

bash CorePlacer.sh Xtightvnc              3
bash CorePlacer.sh mjpg_streamer          3
bash CorePlacer.sh display                3
bash CorePlacer.sh ethernet_app_rpi       3
bash CorePlacer.sh record_core_usage_rpi  3
