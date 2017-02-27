#!/bin/bash

#
# Author: mozcelikors
# Usage:  Check out processes using  "top" command.
#         This script kills the apps that burns cpu cycles
#
# ATTENTION: DO NOT RUN THIS SCRIPT AS ROOT.. NO SUDO

cd /home/pi/process_manipulating_functions/process_functions
bash ProcessKill.sh burn_cycles_around25_1
bash ProcessKill.sh burn_cycles_around25_2
bash ProcessKill.sh burn_cycles_around25_3
bash ProcessKill.sh burn_cycles_around100

