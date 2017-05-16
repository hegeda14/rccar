#!/bin/bash

# This bash script starts the mjpg_streamer using Raspberry Pi Camera driver
# located in the following directory.

cd /home/pi/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental
export LD_LIBRARY_PATH=.
sudo ./mjpg_streamer -i "input_raspicam.so -x 640 -y 480 -fps 30" -o "output_http.so -w /usr/local/www -p 8081"

