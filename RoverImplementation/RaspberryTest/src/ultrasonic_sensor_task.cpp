// Ultrasonic reading using wiringPi for Groove Ultrasonic Ranger
// Author: M.Ozcelikors  <mozcelikors@gmail.com>
// Migrated from Groove Ultrasonic Ranger Python version
// to C/C++

#include "ultrasonic_sensor_task.h"

void setup_GrooveUltrasonicRanger() {
        wiringPiSetup();
}

int getCM_GrooveUltrasonicRanger()
{
		long startTime, stopTime, elapsedTime, distance;
		pinMode(SIG, OUTPUT);
		digitalWrite(SIG, LOW);
		delayMicroseconds(2000);
		digitalWrite(SIG, HIGH);
		delayMicroseconds(5000);
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
		printf("Distance: %d\n", getCM_GrooveUltrasonicRanger());
	}

	/* the function must return something - NULL will do */
	return NULL;
}
