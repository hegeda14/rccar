/*
 * Copyright (c) 2017 PIMES, Fachhochschule Dortmund
 *
 * Description:
 *    Temperature and Humidity Sensor v1.0 Task with wiringPi and pThreads
  *
 * Supervision:
 *    Robert Hottger
 *
 * Authors:
 *    Mustafa Ozcelikors <mozcelikors@gmail.com>   02.02.2017 - compilation
 *
 * Contributors:
 *    Gaël Blondelle - API functions
 *
 * Additional Info:
 *  // Pins:
	//      I2C pins in WiringPi  8 -> SDA       9 -> SCL
	//      I2C pins in BCM       BCM-2 -> SDA   BCM-3 -> SCL
	//      Physical I2c Pins     3 -> SDA       5 -> SCL
	// Preliminaries:
	//      1. sudo raspi-config > Advanced > Enable I2C and SPI
	//      2. In /boot/config.txt, uncomment
	//                              dtparam=i2c_arm=on
	//                              dtparam=i2c=on
	//                              dtparam=spi=on
	//      3. Install following through apt-get:
	//                              i2c-tools
	//                              libi2c-dev
 */

#ifndef TEMPERATURE_TASK_H_
#define TEMPERATURE_TASK_H_

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <wiringPiI2C.h>
#include <unistd.h>
#include "../api/basic_psys_rover.h"
#include "../interfaces.h"
#include <pthread.h>
#include "../RaspberryTest.h"




void *Temperature_Task(void * arg);


#endif /* TEMPERATURE_TASK_H_ */
