/*
 * Copyright (c) 2017 PIMES, Fachhochschule Dortmund
 *
 * Description:
 *    Web Server Back-end communicator
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

#ifndef TASKS_WEBSERVER_MOTORDRIVE_TASK_H_
#define TASKS_WEBSERVER_MOTORDRIVE_TASK_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wiringPi.h>
#include <unistd.h>
#include "../api/basic_psys_rover.h"
#include "../interfaces.h"
#include <pthread.h>
#include "../RaspberryTest.h"
#include <softPwm.h>


void *WebServer_MotorDrive_Task(void * arg);

#endif /* TASKS_WEBSERVER_MOTORDRIVE_TASK_H_ */
