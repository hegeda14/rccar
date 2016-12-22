#!/bin/bash
cd /home/pi/ 
sudo bash webcam_stream_start_from_rpi_camera.sh &
cd /var/www/html/ 
sudo python initialize.py &
sudo python record_core_usage_rpi.py &
sudo python ethernet_app_rpi.py &

