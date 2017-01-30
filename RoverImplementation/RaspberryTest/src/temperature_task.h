// Temperature Task
// Author: Gaël Blondelle
// Contributors: Mustafa Oezcelikoers <mozcelikors@gmail.com>
// The code uses Groove Temperature and Humidity Sensor v1.0
// Pins:
//      I2C pins in WiringPi  8 -> SDA       9 -> SCL
//      I2C pins in BCM       BCM-2 -> SDA   BCM-3 -> SCL
//      Physical I2c Pins     3 -> SDA       5 -> SCL
// Preliminaries:
//      1. sudo raspi-config > Advanced > Enable I2C and SPI
//      2. In /boot/config.txt, uncomment
//                              dtparam=i2c_arm=on
//                              dtparam=i2c=on
//                              dtparam=spi=on

#ifndef TEMPERATURE_TASK_H_
#define TEMPERATURE_TASK_H_

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <wiringPiI2C.h>
#include <unistd.h>
#include "basic_psys_rover.h"

void *Temperature_Task(void *);


#endif /* TEMPERATURE_TASK_H_ */
