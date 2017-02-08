/*
 * Copyright (c) 2017 PIMES, Fachhochschule Dortmund
 *
 * Description:
 *    pThread skeleton for PolarSys rover
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

#include "RaspberryTest.h"

#include "pthread_distribution_lib/pthread_distribution.h"

#include "tasks/ultrasonic_sensor_task.h"
#include "tasks/rover_test_task.h"
#include "tasks/temperature_task.h"
#include "tasks/keycommand_task.h"
#include "tasks/motordriver_task.h"
#include "tasks/infrared_distance_task.h"
#include "tasks/display_sensors_task.h"

#include "interfaces.h"


//Shared data between threads
float temperature_shared;
pthread_mutex_t temperature_lock;

float humidity_shared;
pthread_mutex_t humidity_lock;

int distance_shared;
pthread_mutex_t distance_lock;

char keycommand_shared;
pthread_mutex_t keycommand_lock;

float infrared_shared[2];
pthread_mutex_t infrared_lock;

int main()
{
	wiringPiSetup();

	//Initialize shared data
	temperature_shared = 0.0;
	humidity_shared = 0.0;
	distance_shared = 0;
	keycommand_shared = 'f';
	infrared_shared[0] = 0.0;
	infrared_shared[1] = 0.0;

	//Initialize mutexes
	pthread_mutex_init(&temperature_lock, NULL);
	pthread_mutex_init(&humidity_lock, NULL);
	pthread_mutex_init(&distance_lock, NULL);
	pthread_mutex_init(&keycommand_lock, NULL);
	pthread_mutex_init(&infrared_lock, NULL);

	//Thread objects
	pthread_t main_thread = pthread_self();
	pthread_t ultrasonic_thread;
	pthread_t temperature_thread;
	pthread_t keycommand_input_thread;
	pthread_t motordriver_thread;
	pthread_t infrared_thread;
	pthread_t displaysensors_thread;

	//Thread creation
	if(pthread_create(&ultrasonic_thread, NULL, Groove_Ultrasonic_Sensor_Task, NULL)) {
		fprintf(stderr, "Error creating thread\n");
		return 1;
	}

	if(pthread_create(&temperature_thread, NULL, Temperature_Task, NULL)) {
			fprintf(stderr, "Error creating thread\n");
			return 1;
	}

	if(pthread_create(&keycommand_input_thread, NULL, KeyCommandInput_Task, NULL)) {
			fprintf(stderr, "Error creating thread\n");
			return 1;
	}

	if(pthread_create(&motordriver_thread, NULL, MotorDriver_Task, NULL)) {
			fprintf(stderr, "Error creating thread\n");
			return 1;
	}

	if(pthread_create(&infrared_thread, NULL, InfraredDistance_Task, NULL)) {
			fprintf(stderr, "Error creating thread\n");
			return 1;
	}

	if(pthread_create(&displaysensors_thread, NULL, DisplaySensors_Task, NULL)) {
			fprintf(stderr, "Error creating thread\n");
			return 1;
	}

	//Core pinning/mapping
	placeAThreadToCore (main_thread, 0);
	placeAThreadToCore (ultrasonic_thread, 2);
	placeAThreadToCore (temperature_thread ,3);
	placeAThreadToCore (keycommand_input_thread, 3);
	placeAThreadToCore (motordriver_thread, 1);
	placeAThreadToCore (infrared_thread, 2);
	placeAThreadToCore (displaysensors_thread, 0);

	while (1)
	{
		//What main thread does should come here..
		// ...

	}
	pthread_exit(NULL);

	//Return 0
	return 0;
}

