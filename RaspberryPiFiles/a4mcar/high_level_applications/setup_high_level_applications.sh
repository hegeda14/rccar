#!/bin/bash

#Script Description:
#	A4MCAR Project -	Script that sets up high_level_applications module dependencies.
#
#Author:
#	M. Ozcelikors <mozcelikors@gmail.com>, Fachhochschule Dortmund
#
#Disclaimer:
#	Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
#	All rights reserved. This program and the accompanying materials are made available under the
#	terms of the Eclipse Public License v1.0 which accompanies this distribution, and is available at
#	http://www.eclipse.org/legal/epl-v10.html
#	

echo "### Setting high_level_applications..."
CURRENT_USER=$(whoami)

#Getting the script directory
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do 
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" 
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

echo "### Updating repository list..."
sudo apt-get update

echo "### Cloning external frameworks and libraries..."
cd ~/Downloads
sudo git clone https://gitlab.pimes.fh-dortmund.de/RPublic/a4mcar_required_modules.git

echo "### Copying downloaded libraries into high_level_applications directory..."
sudo cp -r ~/Downloads/a4mcar_required_modules/high_level_applications/virtkeyboard/* $DIR/apps/touchscreen_display/

echo "### Installing psutil..."
sudo apt-get install build-essential python-dev python3-dev python-pkg-resources python3-pkg-resources python-pip
sudo easy_install pip==1.5.6
sudo pip install ~/Downloads/a4mcar_required_modules/high_level_applications/psutil/

echo "### Installing mjpg_streamer and its dependencies..."
sudo apt-get install libjpeg8-dev imagemagick libv4l-dev
sudo ln -s /usr/include/linux/videodev2.h /usr/include/linux/videodev.h
sudo mkdir /home/pi/newmjpg-streamer/mjpg-streamer/
sudo cp -r ~/Downloads/a4mcar_required_modules/high_level_applications/mjpg-streamer/* /home/pi/newmjpg-streamer/mjpg-streamer/
cd /home/pi/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental
sudo make clean
sudo rm -rf CMakeCache.txt
sudo cmake .
sudo make install
sudo cp mjpg_streamer /usr/local/bin/
sudo cp output_http.so input_raspicam.so input_uvc.so /usr/local/lib/
sudo chmod 777 /usr/local/lib/*.so
sudo chmod 777 /usr/local/bin/mjpg_streamer

echo "### Clearing downloaded files..."
sudo rm -rf ~/Downloads/a4mcar_required_modules/

echo "### WHAT TO DO NEXT? ###"
echo "Please install opencv-3.0.0 and raspicam-0.1.3 to proceed with the optional image_processing module"
echo "Before the image_processing module is built, the following variables should be exported"
echo "export OpenCV_DIR=/home/pi/opencv_workspace/opencv/build/"
echo "export raspicam_DIR=/home/pi/raspicam-0.1.3/build/"
echo "### Finished."