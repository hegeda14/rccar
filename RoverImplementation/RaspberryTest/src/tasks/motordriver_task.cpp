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

#include "motordriver_task.h"

void autopark() {
	int i;
	for (i = 0; i < 3; i = i + 1)
	{
		turn(BACKWARD, RIGHT, FULL_SPEED);
	}

	for (i = 0; i < 1; i = i + 1) {
		go(BACKWARD, LOW_SPEED);
	}

	for (i = 0; i < 3; i = i + 1) {
		turn(BACKWARD, LEFT, FULL_SPEED);
	}

	for (i = 0; i < 1; i = i + 1)
	{
		turn(FORWARD, RIGHT, FULL_SPEED);
	}

	for (i = 0; i < 1; i = i + 1) {
		go(BACKWARD, LOW_SPEED);
	}

	stop();
}

void *MotorDriver_Task(void * arg)
{
	init();
	int running = 1;
	char local_command = 'f';

	//runside (LEFT, BACKWARD, FULL_SPEED);
	//runside (RIGHT, BACKWARD, FULL_SPEED);

	while (running)
	{
		pthread_mutex_lock(&keycommand_lock);
			local_command = keycommand_shared;
			//printf("got=%c\n",keycommand_shared);
		pthread_mutex_unlock(&keycommand_lock);




		switch (local_command)
		{
			case 'q':
				running = 0;
				break;
			case 'p':
				autopark();
				break;
			case 'w':
				go(FORWARD, FULL_SPEED);
				break;
			case 'd':
				turn(FORWARD, LEFT, FULL_SPEED);
				break;
			case 's':
				go(BACKWARD, FULL_SPEED);
				break;
			case 'a':
				turn(FORWARD, RIGHT, FULL_SPEED);
				break;
			case 'j':
				turn(BACKWARD, LEFT, FULL_SPEED);
				break;
			case 'l':
				turn(BACKWARD, RIGHT, FULL_SPEED);
				break;
			case 'f':
				stop();
				break;
		}

	}

	/* the function must return something - NULL will do */
	return NULL;
}



