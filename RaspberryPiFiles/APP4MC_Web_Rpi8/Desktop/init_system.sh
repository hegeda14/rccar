#!/bin/bash
sudo cpufreq-set -g performance
cd /home/pi/  && sudo bash webcam_stream_start_from_rpi_camera.sh &

cd /var/www/html/  && sudo python initialize.py &
cd /var/www/html/  && sudo python record_core_usage_rpi.py &
cd /var/www/html/  && sudo python ethernet_app_rpi.py &

cd /home/pi/process_manipulating_functions/burn_cycles && sudo python burn_cycles_around25_1.py &
cd /home/pi/process_manipulating_functions/burn_cycles && sudo python burn_cycles_around25_2.py &
cd /home/pi/process_manipulating_functions/burn_cycles && sudo python burn_cycles_around25_3.py &
cd /home/pi/process_manipulating_functions/burn_cycles && sudo python burn_cycles_around25_4.py &
cd /home/pi/process_manipulating_functions/burn_cycles && sudo python burn_cycles_around25_5.py &
cd /home/pi/process_manipulating_functions/burn_cycles && sudo python burn_cycles_around100.py &
sleep 5
