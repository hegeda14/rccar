#!/bin/bash

#
# Author: mozcelikors
# Usage:  Check out processes using  "top" command.
#         This script starts the apps that burns cpu cycles
#
# ATTENTION: DO NOT RUN THIS SCRIPT AS ROOT.. NO SUDO

cd /home/pi/process_manipulating_functions/burn_cycles
sudo python burn_cycles_around25_1.py &
sudo python burn_cycles_around25_2.py &
sudo python burn_cycles_around25_3.py &
sudo python burn_cycles_around100.py &

