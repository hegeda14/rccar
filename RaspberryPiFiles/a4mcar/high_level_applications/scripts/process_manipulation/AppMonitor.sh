#!/bin/bash

# Prints the process stats given the process name
# Usage: bash AppMonitor.sh <process_name> 
# ATTENTION! Do not run as root

args=("$@")
process_name=${args[0]}
pid=$(pgrep -f $process_name -n ) #Newest result

sudo perf stat -p $pid

