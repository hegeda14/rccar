#!/bin/bash

# Usage:  bash kill_processes.sh
#         This script kills the processes listed below
#
# ATTENTION: DO NOT RUN THIS SCRIPT AS ROOT

cd /home/pi/a4mcar/high_level_applications/scripts/process_manipulation

bash ProcessKill.sh mjpg_streamer
bash ProcessKill.sh touchscreen_display
bash ProcessKill.sh ethernet_client
bash ProcessKill.sh core_recorder
bash ProcessKill.sh dummy_load25_1
bash ProcessKill.sh dummy_load25_2
bash ProcessKill.sh dummy_load25_3
bash ProcessKill.sh dummy_load25_4
bash ProcessKill.sh dummy_load25_5
bash ProcessKill.sh dummy_load100
