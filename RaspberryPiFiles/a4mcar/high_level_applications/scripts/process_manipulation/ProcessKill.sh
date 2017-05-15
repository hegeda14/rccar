#!/bin/bash

# Author: mozcelikors
# Usage: bash ProcessKill.sh <process_name> 
# ATTENTION! Do not call sudo

args=("$@")
process_name=${args[0]}

pid=$(pgrep -u root -f $process_name -n ) #Newest result
pid2=$(pgrep -f display -n) 


echo "Pid  $pid"
echo "Pid2 $pid2"

#Place the task on a specific core.
sudo kill -9 $pid &&
echo "Process $process_name with PID=$pid on core has been killed."

