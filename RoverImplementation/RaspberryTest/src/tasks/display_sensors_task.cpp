/*
 * Copyright (c) 2017 Eclipse Foundation, FH Dortmund and others
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    Displaying Sensor Information with wiringPi and pThreads
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


#include "display_sensors_task.h"

void *DisplaySensors_Task (void * arg)
{
	while (1)
	{
		//pthread_mutex_lock(&temperature_lock);
			printf("Temperature: %f deg\n", temperature_shared);
		//pthread_mutex_unlock(&temperature_lock);
		delayMicroseconds(500000);
		//pthread_mutex_lock(&humidity_lock);
			printf("Humidity: %f percent\n", humidity_shared);
		//pthread_mutex_unlock(&humidity_lock);
		delayMicroseconds(500000);
		//pthread_mutex_lock(&distance_lock);
			printf("Distance: %d cm\n", distance_shared);
		//pthread_mutex_unlock(&distance_lock);
		//pthread_mutex_lock(&infrared_lock);
			printf("DistanceInfraredChan0: %f cm\n", infrared_shared[0]);
			printf("DistanceInfraredChan1: %f cm\n", infrared_shared[1]);
		//pthread_mutex_unlock(&infrared_lock);
		delayMicroseconds(500000);
	}

	/* the function must return something - NULL will do */
	return NULL;
}

