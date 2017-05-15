#!/bin/bash
sudo cpufreq-set -g performance
cd /home/pi/a4mcar/high_level_applications/scripts/camera_start  && sudo bash raspberrypi_camera_start.sh &

cd /home/pi/a4mcar/high_level_applications/apps/initialize && sudo python initialize.py &
cd /home/pi/a4mcar/high_level_applications/apps/core_recorder && sudo python core_recorder.py &
cd /home/pi/a4mcar/high_level_applications/apps/ethernet_client  && sudo python ethernet_client.py &

cd /home/pi/a4mcar/high_level_applications/apps/dummy_loads && sudo python dummy_load25_1.py &
cd /home/pi/a4mcar/high_level_applications/apps/dummy_loads && sudo python dummy_load25_2.py &
cd /home/pi/a4mcar/high_level_applications/apps/dummy_loads && sudo python dummy_load25_3.py &
cd /home/pi/a4mcar/high_level_applications/apps/dummy_loads && sudo python dummy_load25_4.py &
cd /home/pi/a4mcar/high_level_applications/apps/dummy_loads && sudo python dummy_load25_5.py &
cd /home/pi/a4mcar/high_level_applications/apps/dummy_loads && sudo python dummy_load100.py &
sleep 5
