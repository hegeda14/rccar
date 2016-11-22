#!/usr/bin/env python
import psutil
import time
import string

text_file = open("ethernet_command_to_xmos_history.inc","w")
text_file.write("NOCHANGE")
text_file.close()
text_file2 = open("ethernet_command_to_xmos.inc","w")
text_file2.write("NOCHANGE")
text_file2.close()
