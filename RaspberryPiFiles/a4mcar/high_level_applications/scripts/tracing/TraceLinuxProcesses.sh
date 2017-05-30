#!/bin/bash
# Copyright (c) 2017 FH Dortmund and others
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Description:
#	Linux shell (bash) script that traces linux processes and converts
#	the trace to common tracing format (CTF).
#	perf module should be compiles with libbabeltrace in order to run
#	the tracing utility correctly.
#	Created out directory will contain Processes_List.txt (process IDs
#	are listed), perf.data (trace in perf format), ctf_trace.tar.gz
#	(trace in ctf format)
#	The ctf_format.tar.gz can be extracted in order to visualize the 
#	perf streams using Eclipse TraceCompass.
#
# Usage:
#	sudo TraceLinuxProcesses.sh <trace_name> <period> <path_to_perf>
#	e.g. sudo TraceLinuxProcesses.sh APP4MC_Trace 15 /home/pi/linux/tools/perf
#	<trace_name>:	Trace name for the output
#	<period>:	Amount of time in seconds to trace the system
#	<path_to_perf>:	Installed perf directory that contains ./perf
#
# Authors:
#	M. Ozcelikors <mozcelikors@gmail.com>, FH Dortmund
#

args=("$@")
trace_name=${args[0]}
seconds=${args[1]}
perf_directory=${args[2]}

if [ "$#" -ne 3 ]; then
	echo "Entered arguments seem to be incorrect"
	echo "Right usage: sudo TraceLinuxProcesses.sh <trace_name> <period> <path_to_perf>"
	echo "e.g. sudo TraceLinuxProcesses.sh APP4MC_Trace 15 /home/pi/linux/tools/perf"
else
	echo "### Creating directory.."
	sudo mkdir out_$trace_name/
	echo "### Writing out process names.."
	ps -aux >> out_$trace_name/Processes_List.txt
	echo "### Tracing with perf for $seconds seconds.."
	sudo $perf_directory/./perf sched record -o out_$trace_name/perf.data -- sleep $seconds
	echo "### Converting to data to CTF (Common Tracing Format).."
	sudo LD_LIBRARY_PATH=/opt/libbabeltrace/lib $perf_directory/./perf data convert -i out_$trace_name/perf.data --to-ctf=./ctf
	sudo tar -czvf out_$trace_name/trace.tar.gz ctf/
	sudo rm -rf ctf/
	
	echo "### Process IDs are written to out_$trace_name/Processes_List.txt"
	echo "### Trace in Perf format is written to out_$trace_name/perf.data"
	echo "### Trace in CTF format is written to out_$trace_name/trace.tar.gz"
	echo "### Exiting.."
fi





