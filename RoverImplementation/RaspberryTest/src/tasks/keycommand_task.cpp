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


#include "keycommand_task.h"


void *KeyCommandInput_Task(void * arg)
{
	char keys;
	int running = 1;
	while (running)
	{
		pthread_mutex_lock(&keycommand_lock);
			keys = getchar();
			if (isalpha(keys))
			{
				keycommand_shared = keys;
				printf("Entered Command = %c\n",keycommand_shared);
			}
		pthread_mutex_unlock(&keycommand_lock);
		delayMicroseconds(200000);
	}

	/* the function must return something - NULL will do */
	return NULL;
}
