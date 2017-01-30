// Threading example with PSys rover, temperature sensor and ultrasonic sensor
// Author: M.Ozcelikors  <mozcelikors@gmail.com>
// Can be built with:
//    g++ RaspberryTest.cpp -lwiringPi -lpthread

#include <pthread.h>
#include <iostream>
#include <stdlib.h>
#include <unistd.h>

#include "pthread_distribution.h"
#include "ultrasonic_sensor_task.h"
#include "rover_test_task.h"
#include "temperature_task.h"

using namespace std;

int main()
{
	//Thread objects
	pthread_t main_thread = pthread_self();
	pthread_t rovertest_thread;
	pthread_t ultrasonic_thread;
	pthread_t temperature_thread;

	//Thread creation
	if(pthread_create(&ultrasonic_thread, NULL, Groove_Ultrasonic_Sensor_Task, NULL)) {
		fprintf(stderr, "Error creating thread\n");
		return 1;
	}

	if(pthread_create(&temperature_thread, NULL, Temperature_Task, NULL)) {
			fprintf(stderr, "Error creating thread\n");
			return 1;
		}

	if(pthread_create(&rovertest_thread, NULL, Rover_Test_Task, NULL)) {
		fprintf(stderr, "Error creating thread\n");
		return 1;
	}

	//Core pinning/mapping
	placeAThreadToCore (main_thread, 0);
	placeAThreadToCore (rovertest_thread, 1);
	placeAThreadToCore (ultrasonic_thread, 2);
	placeAThreadToCore (temperature_thread ,3);

	while (1)
	{
		//What main thread does should come here..
	}
	// ...

	//Return 0
	return 0;
}


/*

// Ultrasonic for wiringPi for both HCSR-04 and Groove Ultrasonic Ranger
// Author: M.Ozcelikors  <mozcelikors@gmail.com>
// Migrated from Groove Ultrasonic Ranger Python version
// to C/C++
// Can be built with:
//    g++ ultrasonic.c -lwiringPi

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>

//If you use HCSR-04
#define TRIG 5
#define ECHO 6

//If you use GrooveUltrasonicRanger
#define SIG 6

void setupHCSR04() {
        wiringPiSetup();
        pinMode(TRIG, OUTPUT);
        pinMode(ECHO, INPUT);

        //TRIG pin must start LOW
        digitalWrite(TRIG, LOW);
        delay(30);
}

void setup_GrooveUltrasonicRanger() {
        wiringPiSetup();
}

int getCM_HCSR04() {
        //Send trig pulse
        digitalWrite(TRIG, HIGH);
        delayMicroseconds(20);
        digitalWrite(TRIG, LOW);

        //Wait for echo start
        while(digitalRead(ECHO) == LOW);

        //Wait for echo end
        long startTime = micros();
        while(digitalRead(ECHO) == HIGH);
        long travelTime = micros() - startTime;

        //Get distance in cm
        int distance = travelTime / 58;

        return distance;
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

int main(void) {
	    setup_GrooveUltrasonicRanger();
        printf("Distance: %dcm\n", getCM_GrooveUltrasonicRanger());

        return 0;
}
*/

/*#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <wiringPi.h>
#include "basic_psys_rover.c"
#include "basic_psys_rover.h"


void say(char *text){
   char buffer[1024];

   strcpy(buffer,"flite -voice rms -t \"");
   strcat(buffer, text);
   strcat(buffer,"\"");

   system(buffer);
}

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

void getDistanceTrain(int channel,int rounds){
	int i;
	for (i=0 ; i<rounds ; i++){
		printf("Distance channel (cm) %d:%f\n",channel,getDistance(channel));
		delay(500);
	}
}

int main(void) {

	printf("Raspberry Pi Basic Rover test \n");

	init();
	int running = 1;

	while (running) {
		int c = getchar();

		switch (c) {
		case 'q':
			running = 0;
			break;
		case 'p':
			autopark();
			break;
		case 'i':
			go(FORWARD, FULL_SPEED);
			break;
		case 'u':
			turn(FORWARD, LEFT, FULL_SPEED);
			break;
		case 'k':
			go(BACKWARD, FULL_SPEED);
			break;
		case 'o':
			turn(FORWARD, RIGHT, FULL_SPEED);
			break;
		case 'j':
			turn(BACKWARD, LEFT, FULL_SPEED);
			break;
		case 'l':
			turn(BACKWARD, RIGHT, FULL_SPEED);
			break;
		case 'c':
			getTemperature();
			break;
		case 'd':
			printf("Distance channel %d:%f\n",0,getDistance(0));
			break;
		case 'e':
			printf("Distance channel %d:%f\n",1,getDistance(1));
			break;
		case 'r':
			getDistanceTrain(0,10);
			break;
		case 'f':
			getDistanceTrain(1,10);
			break;
		case 'h':
			getHumidity();
			break;
		case 's':
			stop();
			break;
		case 't':
			toggle_light();
			break;
		case 'w':
			say("Good morning! I am the PolarSys Rover!");
			break;
		}
	}

	printf("Raspberry Pi Basic Rover exit\n");

	stop();

	return EXIT_SUCCESS;
}*/
