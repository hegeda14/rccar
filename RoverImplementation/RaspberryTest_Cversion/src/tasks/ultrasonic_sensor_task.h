/*
 * Copyright (c) 2017 PIMES, Fachhochschule Dortmund
 *
 * Description:
 *    Groove Ultrasonic Sensor Task with wiringPi and pThreads
 *
 * Supervision:
 *    Robert Hottger
 *
 * Authors:
 *    Mustafa Ozcelikors <mozcelikors@gmail.com>   02.02.2017 - compilation
 *
 * Contributors:
 *
 * Additional:
 * 	  Migrated from Groove Ultrasonic Sensor Python Library
 */

#ifndef ULTRASONIC_SENSOR_TASK_H_
#define ULTRASONIC_SENSOR_TASK_H_

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <pthread.h>
#include "../RaspberryTest.h"

//Pin for SIG input
// BCM-5,  Physical 29, wiringPi 21
// BCM-25,  Physical 22, wiringPi 6
#define SIG 21

void *Groove_Ultrasonic_Sensor_Task(void *);
int getCM_GrooveUltrasonicRanger();
void setup_GrooveUltrasonicRanger();

#endif /* ULTRASONIC_SENSOR_TASK_H_ */
