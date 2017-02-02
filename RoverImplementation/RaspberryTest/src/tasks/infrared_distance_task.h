/*
 * Copyright (c) 2017 PIMES, Fachhochschule Dortmund
 *
 * Description:
 *    Infrared Distance Sensor Task with wiringPi and pThreads
 *
 * Supervision:
 *    Robert Hottger
 *
 * Authors:
 *    Mustafa Ozcelikors <mozcelikors@gmail.com>   02.02.2017 - compilation
 *
 * Contributors:
 *    Gaël Blondelle - API functions
 */

#ifndef INFRARED_DISTANCE_TASK_H_
#define INFRARED_DISTANCE_TASK_H_


#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <unistd.h>
#include "../api/basic_psys_rover.h"
#include "../interfaces.h"
#include <pthread.h>
#include <mcp3004.h>

#include "../RaspberryTest.h"



void *InfraredDistance_Task (void * arg);

#endif /* INFRARED_DISTANCE_TASK_H_ */
