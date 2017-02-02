/*
 * Copyright (c) 2017 PIMES, Fachhochschule Dortmund
 *
 * Description:
 *    Groove Ultrasonic Sensor Task with wiringPi and pThreads
 *
 * Supervision:
 *    Robert Hottger
 *
 * Authors:
 *    Mustafa Ozcelikors <mozcelikors@gmail.com>   02.02.2017 - compilation
 *
 * Contributors:
 *
 * Additional:
 * 	  Migrated from Groove Ultrasonic Sensor Python Library
 */

#include "ultrasonic_sensor_task.h"

void setup_GrooveUltrasonicRanger() {
        //wiringPiSetup();   //Since this can only be used once in a program, we do it in main and comment this.
}

int getCM_GrooveUltrasonicRanger()
{
		long startTime, stopTime, elapsedTime, distance;
		pinMode(SIG, OUTPUT);
		digitalWrite(SIG, LOW);
		delayMicroseconds(2);
		digitalWrite(SIG, HIGH);
		delayMicroseconds(5);
		digitalWrite(SIG,LOW);
		startTime = micros();
		pinMode(SIG,INPUT);
		while (digitalRead(SIG) == LOW)
			startTime = micros();
		while (digitalRead(SIG) == HIGH)
			stopTime = micros();
		elapsedTime = stopTime - startTime;
		distance = elapsedTime * 34300;
		distance = distance / 1000000;
		distance = distance / 2;
		return distance;
}


void *Groove_Ultrasonic_Sensor_Task(void *unused)
{
	setup_GrooveUltrasonicRanger();
	while (1)
	{
		pthread_mutex_lock(&distance_lock);
			distance_shared = getCM_GrooveUltrasonicRanger();
		pthread_mutex_unlock(&distance_lock);
		//printf("Distance: %dcm\n", getCM_GrooveUltrasonicRanger());
		delayMicroseconds(500000);
	}

	//the function must return something - NULL will do
	return NULL;
}
