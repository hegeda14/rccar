#!/bin/bash

# Kills a process given its name
# Usage: bash ProcessKill.sh <process_name> 
# ATTENTION! Do not run as root

args=("$@")
process_name=${args[0]}

pid=$(pgrep -u root -f $process_name -n ) #Newest result

#Place the task on a specific core.
sudo kill -9 $pid &&
echo "Process $process_name with PID=$pid on core has been killed."

