#!/bin/bash

#
# Author: mozcelikors
# Usage:  Check out processes using  "top" command.
#         This script places every app to designated cores
#
# ATTENTION: DO NOT RUN THIS SCRIPT AS ROOT.. NO SUDO

cd /home/pi/process_manipulating_functions/process_functions
bash initCore1Placement.sh
bash initCore2Placement.sh
bash initCore3Placement.sh
