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
text_file3 = open("core_usage_xmos.inc","w")
text_file3.write("0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0")
text_file3.close()
text_file4 = open("deadline_logger_ethernet_app_rpi.inc","w")
text_file4.write("0 0")
text_file4.close()
text_file5 = open("deadline_logger_record_core_usage_rpi.inc","w")
text_file5.write("0 0")
text_file5.close()
text_file6 = open("/home/pi/process_manipulating_functions/burn_cycles/deadline_logger_burn_cycles_around25_1.inc","w")
text_file6.write("0 0")
text_file6.close()
text_file7 = open("/home/pi/process_manipulating_functions/burn_cycles/deadline_logger_burn_cycles_around25_2.inc","w")
text_file7.write("0 0")
text_file7.close()
text_file8 = open("/home/pi/process_manipulating_functions/burn_cycles/deadline_logger_burn_cycles_around25_3.inc","w")
text_file8.write("0 0")
text_file8.close()
text_file8 = open("/home/pi/process_manipulating_functions/burn_cycles/deadline_logger_burn_cycles_around25_4.inc","w")
text_file8.write("0 0")
text_file8.close()
text_file9 = open("/home/pi/process_manipulating_functions/burn_cycles/deadline_logger_burn_cycles_around25_5.inc","w")
text_file9.write("0 0")
text_file9.close()
text_file10 = open("/home/pi/process_manipulating_functions/burn_cycles/deadline_logger_burn_cycles_around100.inc","w")
text_file10.write("0 0")
text_file10.close()


