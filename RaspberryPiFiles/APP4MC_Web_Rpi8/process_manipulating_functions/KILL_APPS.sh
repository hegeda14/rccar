#!/bin/bash

#
# Author: mozcelikors
# Usage:  Check out processes using  "top" command.
#         This script kills the processes listed below
#
# ATTENTION: DO NOT RUN THIS SCRIPT AS ROOT.. NO SUDO

cd /home/pi/process_manipulating_functions/process_functions

bash ProcessKill.sh mjpg_streamer
bash ProcessKill.sh display
bash ProcessKill.sh ethernet_app_rpi
bash ProcessKill.sh record_core_usage_rpi
bash ProcessKill.sh burn_cycles_around25_1
bash ProcessKill.sh burn_cycles_around25_2
bash ProcessKill.sh burn_cycles_around25_3
bash ProcessKill.sh burn_cycles_around25_4
bash ProcessKill.sh burn_cycles_around25_5
bash ProcessKill.sh burn_cycles_around100
