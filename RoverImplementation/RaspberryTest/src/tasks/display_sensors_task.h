/*
 * Copyright (c) 2017 PIMES, Fachhochschule Dortmund
 *
 * Description:
 *    Sensor Displaying Task with wiringPi and pThreads
  *
 * Supervision:
 *    Robert Hottger
 *
 * Authors:
 *    Mustafa Ozcelikors <mozcelikors@gmail.com>   02.02.2017 - compilation
 *
 * Contributors:
 *
 */

#ifndef DISPLAY_SENSORS_TASK_H_
#define DISPLAY_SENSORS_TASK_H_


#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <unistd.h>
#include "../api/basic_psys_rover.h"
#include "../interfaces.h"
#include <pthread.h>

#include "../RaspberryTest.h"

void *DisplaySensors_Task (void * arg);

#endif /* DISPLAY_SENSORS_TASK_H_ */
