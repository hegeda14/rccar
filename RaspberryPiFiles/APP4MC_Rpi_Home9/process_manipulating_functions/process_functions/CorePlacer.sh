#!/bin/bash

# Author: mozcelikors
# Usage: bash CorePlacer.sh <process_name> <core_affinity>
# ATTENTION! Do not call sudo

args=("$@")
process_name=${args[0]}
core=${args[1]}  #Affinity, 0-3 for raspberry pi, could be a range too.
pid=$(pgrep -f $process_name -n ) #Newest result
pid2=$(pgrep -f $process_name -u root -n) 


echo "Pid  $pid"
echo "Pid2 $pid2"

#Place the task on a specific core.
sudo taskset -pc $core $pid &&
echo "Process $process_name with PID=$pid has been placed on core $core"

