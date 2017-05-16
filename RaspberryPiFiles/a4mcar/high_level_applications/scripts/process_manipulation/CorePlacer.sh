#!/bin/bash

# Places a process given its name to a core
# Usage: bash CorePlacer.sh <process_name> <core_affinity>
# ATTENTION! Do not run as root

args=("$@")
process_name=${args[0]}
core=${args[1]}  #Affinity, 0-3 for raspberry pi, could be a range too.
pid=$(pgrep -f $process_name -n ) #Newest result

#Place the task on a specific core.
sudo taskset -pc $core $pid &&
echo "Process $process_name with PID=$pid has been placed on core $core"

