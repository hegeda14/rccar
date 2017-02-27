#!/bin/bash

# Author: mozcelikors
# Usage: bash AppMonitor.sh <process_name> 
# ATTENTION! Do not call sudo

args=("$@")
process_name=${args[0]}
pid=$(pgrep -f $process_name -n ) #Newest result
pid2=$(pgrep -f $process_name -u root -n) 


echo "Pid  $pid"
echo "Pid2 $pid2"

sudo perf stat -p $pid

