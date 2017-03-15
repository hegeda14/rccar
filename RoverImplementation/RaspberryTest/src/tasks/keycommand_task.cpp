/*
 * Copyright (c) 2017 Eclipse Foundation, FH Dortmund and others
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    Key command obtainer function with pThreads
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
				//printf("Entered Command = %c\n",keycommand_shared);
			}
		pthread_mutex_unlock(&keycommand_lock);
		delayMicroseconds(200000);
	}

	/* the function must return something - NULL will do */
	return NULL;
}
