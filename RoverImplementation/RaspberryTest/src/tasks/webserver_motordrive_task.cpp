/*
 * Copyright (c) 2017 Eclipse Foundation, FH Dortmund and others
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    Communicating with web server back-end via file access
 *
 *    In order to drive your rover via web page, please follow instructions from:
 *       https://gitlab.pimes.fh-dortmund.de/RPublic/RoverWeb/raw/master/documentation/RoverWebpageDocumentation.pdf
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

#include "webserver_motordrive_task.h"

void *WebServer_MotorDrive_Task(void * arg)
{
	FILE *fp;
	char ch;

	while(1)
	{
		fp = fopen("/var/www/html/ROVER_CMD.inc", "r");
		ch = fgetc (fp);
		//printf("Got command = %c\n", ch);
		pthread_mutex_lock(&keycommand_lock);
		keycommand_shared = tolower(ch);
		pthread_mutex_unlock(&keycommand_lock);
		fclose(fp);
		delayMicroseconds(50000);//50ms
	}
}


