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

#include "infrared_distance_task.h"

void setupInfraredSensors()
{
	// Init the analog digital converter
		  mcp3004Setup (BASE, SPI_CHAN); // 3004 and 3008 are the same 4/8 channels
}

float getDistanceFromInfraredSensor(int channel){
	float x;
	float y=analogRead (BASE+channel);

// 1/cm to output voltage is almost linear between
// 80cm->0,4V->123
// 6cm->3,1V->961
// => y=5477*x+55 => x= (y-55)/5477
	if (y<123){
		x=100.00;
	} else {
		float inverse = (y-55)/5477;
		//printf("inverse=%f\n",inverse);
	// x is the distance in cm
		x = 1/inverse;
	}

    //printf("Distance channel row data %d:%f\n",channel,y);
    //printf("Distance channel (cm) %d:%f\n",channel,x);

	return x;
}

void *InfraredDistance_Task (void * arg)
{
	//setupInfraredSensors();
	int chan;
	while (1)
	{
		//Setting argument in pthread - whenever you R/W access to temperature_shared, you have to do the same.
		pthread_mutex_lock(&infrared_lock);
			for (chan = 0; chan <= 1; chan ++)
			{
				infrared_shared[chan] = getDistanceFromInfraredSensor(chan);
			}
		pthread_mutex_unlock(&infrared_lock);
		delayMicroseconds(500000);
	}

	/* the function must return something - NULL will do */
	return NULL;
}

