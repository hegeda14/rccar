#!/bin/bash
export LD_LIBRARY_PATH=/usr/local/lib/
sudo mkdir /tmp/stream/
sudo raspistill --nopreview -t 9999999 -w 640 -h 480 -q 5 -o /tmp/stream/pic.jpg -tl 10 -vf  -th 0:0:0 &
/usr/local/bin/mjpg_streamer -i "input_file.so -f /tmp/stream/ -n pic.jpg" -o "output_http.so -w /usr/local/www -p 8081"

