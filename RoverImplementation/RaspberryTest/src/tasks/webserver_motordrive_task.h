/*
 * Copyright (c) 2017 Eclipse Foundation, FH Dortmund and others
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    Communicating with web server back-end via file access
 *
 *    In order to drive your rover via web page, please follow instructions from:
 *       https://gitlab.pimes.fh-dortmund.de/RPublic/RoverWeb/raw/master/documentation/RoverWebpageDocumentation.pdf
 *
 * Authors:
 *    M. Ozcelikors,            R.Hottger
 *    <mozcelikors@gmail.com>   <robert.hoettger@fh-dortmund.de>
 *
 * Contributors:
 *
 * Update History:
 *    02.02.2017   -    first compilation
 *    15.03.2017   -    updated tasks for web-based driving
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
