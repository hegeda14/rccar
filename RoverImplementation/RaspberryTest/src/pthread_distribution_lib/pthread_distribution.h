/*
 * Copyright (c) 2017 PIMES, Fachhochschule Dortmund
 *
 * Description:
 *    pThread Core Affinity Pinning
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

#ifndef PTHREAD_DISTRIBUTION_H_
#define PTHREAD_DISTRIBUTION_H_

//Includes needed
#include <pthread.h>
#include <iostream>
#include <stdlib.h>
#include <unistd.h>
#include <sched.h>
#include <cstdio>
#include <errno.h>
#include <pthread.h>

int placeThisThreadToCore(int core_id);
int placeAThreadToCore (pthread_t thread, int core_id);


#endif /* PTHREAD_DISTRIBUTION_H_ */
