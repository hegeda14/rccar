#!/bin/bash

#Script Description:
#	A4MCAR Project -	Script that sets up web_interface module
#						Installs Apache2, PHP5, allows user privilages and installs required libraries
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

echo "### Setting up web_interface..."
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

echo "### Installing apache2 and php5..."
sudo apt-get install apache2 -y
sudo apt-get install php5 libapache2-mod-php5 -y

echo "### Adjusting web server permissions..."
sudo chgrp -R www-data /var/www/html
sudo find /var/www/html -type -d -exec chmod g+rx {} +
sudo find /var/www/html -type f -exec chmod g+r {} +
sudo chown $CURRENT_USER /var/www/html/
sudo find /var/www/html/ -type d -exec chmod u+rwx {} +
sudo find /var/www/html/ -type f -exec chmod u+rw {} +

echo "### Copying the folder contents into /var/www/html/..."
sudo cp -r $DIR/* /var/www/html

echo "### Allowing script permissions to www-data..."
sudo -i
sudo echo "www-data	ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
exit
# Or sudo echo "www-data	ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers, But script has to be run as root..

echo "### Cloning external frameworks and libraries..."
cd ~/Downloads
sudo git clone https://gitlab.pimes.fh-dortmund.de/RPublic/a4mcar_required_modules.git

echo "### Copying downloaded libraries into /var/www/html..."
sudo mkdir /var/www/html/jqplot_dist
sudo cp -r ~/Downloads/a4mcar_required_modules/web_interface/jqplot_dist/* /var/www/html/jqplot_dist
sudo mkdir /var/www/html/jquery_ui
sudo cp -r ~/Downloads/a4mcar_required_modules/web_interface/jquery_ui/* /var/www/html/jquery_ui
sudo cp ~/Downloads/a4mcar_required_modules/web_interface/jq.js /var/www/html/

echo "### Clearing downloaded files..."
sudo rm -rf ~/Downloads/a4mcar_required_modules/

echo "### Finished."