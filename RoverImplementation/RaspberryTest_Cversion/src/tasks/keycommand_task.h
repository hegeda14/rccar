/*
 * Copyright (c) 2017 PIMES, Fachhochschule Dortmund
 *
 * Description:
 *    Key command obtainer function with pThreads
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

#ifndef KEYCOMMAND_TASK_H_
#define KEYCOMMAND_TASK_H_

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <unistd.h>
#include "../api/basic_psys_rover.h"
#include "../interfaces.h"
#include <pthread.h>
#include "../RaspberryTest.h"
#include <ctype.h>

void *KeyCommandInput_Task(void * arg);

#endif /* KEYCOMMAND_TASK_H_ */
