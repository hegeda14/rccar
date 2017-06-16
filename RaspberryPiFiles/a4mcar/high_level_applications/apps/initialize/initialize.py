#!/usr/bin/env python

# Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Description:
#    A4MCAR Project - Sets up high-level module log files with initial values
#
# Author:
#    M. Ozcelikors <mozcelikors@gmail.com>

import psutil
import time
import string

text_file = open("../../logs/driving/driving_command.inc","w")
text_file.write("NOCHANGE")
text_file.close()
text_file = open("../../logs/driving/driving_command_history.inc","w")
text_file.write("NOCHANGE")
text_file.close()
text_file = open("/var/www/html/core_usage_xmos.inc","w")
text_file.write("0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0")
text_file.close()
text_file = open("../../logs/timing/ethernet_client_timing.inc","w")
text_file.write("0 0 0 0")
text_file.close()
text_file = open("../../logs/timing/core_recorder_timing.inc","w")
text_file.write("0 0 0 0")
text_file.close()
text_file = open("../../logs/timing/dummy_load25_1_timing.inc","w")
text_file.write("0 0 0 0")
text_file.close()
text_file = open("../../logs/timing/dummy_load25_2_timing.inc","w")
text_file.write("0 0 0 0")
text_file.close()
text_file = open("../../logs/timing/dummy_load25_3_timing.inc","w")
text_file.write("0 0 0 0")
text_file.close()
text_file = open("../../logs/timing/dummy_load25_4_timing.inc","w")
text_file.write("0 0 0 0")
text_file.close()
text_file = open("../../logs/timing/dummy_load25_5_timing.inc","w")
text_file.write("0 0 0 0")
text_file.close()
text_file = open("../../logs/timing/dummy_load100_timing.inc","w")
text_file.write("0 0 0 0")
text_file.close()
text_file = open("../../logs/timing/image_processing_timing.inc","w")
text_file.write("0 0 0 0")
text_file.close()
text_file = open("../../logs/image_processing/detection.inc","w")
text_file.write("undetected")
text_file.close()


