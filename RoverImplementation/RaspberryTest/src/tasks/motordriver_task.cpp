/*
 * Copyright (c) 2017 Eclipse Foundation, FH Dortmund and others
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    Motor driving Task with wiringPi and pThreads
 *
 * Authors:
 *    M. Ozcelikors,            R.Hottger
 *    <mozcelikors@gmail.com>   <robert.hoettger@fh-dortmund.de>
 *
 * Contributors:
 *    Gael Blondelle - API functions
 *
 * Update History:
 *    02.02.2017   -    first compilation
 *    15.03.2017   -    updated tasks for web-based driving
 *
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
			case 'g':
				running = 0;
				break;
			case 'p':
				autopark();
				break;
			case 'w':
				go(FORWARD, FULL_SPEED);
				break;
			case 'd':
				turn(BACKWARD, LEFT, FULL_SPEED);
				break;
			case 's':
				go(BACKWARD, FULL_SPEED);
				break;
			case 'a':
				turn(BACKWARD, RIGHT, FULL_SPEED);
				break;
			case 'q':
				turn(FORWARD, RIGHT, FULL_SPEED);
				break;
			case 'e':
				turn(FORWARD, LEFT, FULL_SPEED);
				break;
			case 'f':
				stop();
				break;
		}

	}

	/* the function must return something - NULL will do */
	return NULL;
}



