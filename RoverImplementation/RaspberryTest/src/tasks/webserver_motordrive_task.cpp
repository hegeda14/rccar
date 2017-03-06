/*
 * Copyright (c) 2017 PIMES, Fachhochschule Dortmund
 *
 * Description:
 *    Web Server Back-end communicator
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


