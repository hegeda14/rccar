#!/bin/bash

# This bash script starts the mjpg_streamer using UVC driver (webcam)
# located in the following directory.

export LD_LIBRARY_PATH=/usr/local/lib/
/usr/local/bin/mjpg_streamer -i "input_uvc.so -n pic.jpg -q 50" -o "output_http.so -w /usr/local/www -p 8081"

