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

#include "display_sensors_task.h"

void *DisplaySensors_Task (void * arg)
{
	while (1)
	{
		pthread_mutex_lock(&temperature_lock);
			printf("Temperature: %f deg\n", temperature_shared);
		pthread_mutex_unlock(&temperature_lock);
		delayMicroseconds(500000);
		pthread_mutex_lock(&humidity_lock);
			printf("Humidity: %f percent\n", humidity_shared);
		pthread_mutex_unlock(&humidity_lock);
		delayMicroseconds(500000);
		pthread_mutex_lock(&distance_lock);
			printf("Distance: %d cm\n", distance_shared);
		pthread_mutex_unlock(&distance_lock);
		pthread_mutex_lock(&infrared_lock);
			printf("DistanceInfraredChan0: %f cm\n", infrared_shared[0]);
			printf("DistanceInfraredChan1: %f cm\n", infrared_shared[1]);
		pthread_mutex_unlock(&infrared_lock);
		delayMicroseconds(500000);
	}

	/* the function must return something - NULL will do */
	return NULL;
}

