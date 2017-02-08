/*
 * Copyright (c) 2017 PIMES, Fachhochschule Dortmund
 *
 * Description:
 *    Motor driving Task with wiringPi and pThreads
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

#ifndef MOTORDRIVER_TASK_H_
#define MOTORDRIVER_TASK_H_


#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <unistd.h>
#include "../api/basic_psys_rover.h"
#include "../interfaces.h"
#include <pthread.h>
#include "../RaspberryTest.h"
#include <softPwm.h>

void *MotorDriver_Task(void * arg);



#endif /* MOTORDRIVER_TASK_H_ */
