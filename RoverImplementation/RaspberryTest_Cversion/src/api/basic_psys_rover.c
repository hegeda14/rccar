/*
 * Copyright (c) 2016 Eclipse Foundation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Authors:
 *    Gaël Blondelle - initial implementation
 * Contributors:
 */

#include <wiringPi.h>
#include <mcp3004.h>
#include <softPwm.h>
#include <wiringPiI2C.h>
#include <stdio.h>
#include <unistd.h>

#include "basic_psys_rover.h"

static int led_status = 0;
static int i2c_th02_fd = 0;

void init(){
	  //wiringPiSetup () ;

	  pinMode (ENABLE_MOTOR_LEFT, OUTPUT) ;
	  digitalWrite (ENABLE_MOTOR_LEFT, HIGH) ;
	  pinMode (ENABLE_MOTOR_RIGHT, OUTPUT) ;
	  digitalWrite (ENABLE_MOTOR_RIGHT, HIGH) ;
	  pinMode (DIRECTION_PIN_LEFT, OUTPUT) ;
	  pinMode (DIRECTION_PIN_RIGHT, OUTPUT) ;


	softPwmCreate (SOFT_PWM_ENGINE_LEFT, 0, FULL_SPEED) ;
	softPwmCreate (SOFT_PWM_ENGINE_RIGHT, 0, FULL_SPEED) ;

	pinMode (FLASH_LIGHT_LED, OUTPUT) ;

// Init the analog digital converter
	  mcp3004Setup (BASE, SPI_CHAN); // 3004 and 3008 are the same 4/8 channels

// Init the I2C interface for device 0x40 which is the id of the temperature/humidity sensor
	   i2c_th02_fd = wiringPiI2CSetup (0x40);
}

float getDistance(int channel){
	float x;
	float y=analogRead (BASE+channel);

// 1/cm to output voltage is almost linear between
// 80cm->0,4V->123
// 6cm->3,1V->961
// => y=5477*x+55 => x= (y-55)/5477
	if (y<123){
		x=100.00;
	} else {
		float inverse = (y-55)/5477;
		printf("inverse=%f\n",inverse);
	// x is the distance in cm
		x = 1/inverse;
	}

    printf("Distance channel row data %d:%f\n",channel,y);
    printf("Distance channel (cm) %d:%f\n",channel,x);

	return x;
}

float getTemperature(){
	float x;

	unsigned char command[2]= {0};

	command[0]=0x03;
	command[1]=0x11;

	printf("fd:%d\n",i2c_th02_fd);

//	wiringPiI2CWriteReg8(i2c_th02_fd, 0x03, 0x01);

	write(i2c_th02_fd,command,2);

	// Poll RDY (D0) in STATUS (register 0) until it is low (=0)
	int status = -1;
	delay (30);
	while ((status & 0x01) != 0) {
		status = wiringPiI2CReadReg8(i2c_th02_fd,0);
		printf("Status:%d\n",status);
	}

	// Read the upper and lower bytes of the temperature value from
	// DATAh and DATAl (registers 0x01 and 0x02), respectively
	unsigned char buffer[3]= {0};
    read(i2c_th02_fd, buffer, 3);

	int dataH = buffer[1] & 0xff;
	int dataL = buffer[2] & 0xff;

//	int dataH = wiringPiI2CRead(i2c_th02_fd)&0xff;
//	int dataL = wiringPiI2CRead(i2c_th02_fd)&0xff;
	printf("dataH:%02X\n",dataH);
	printf("dataL:%02X\n",dataL);

	x = (dataH * 256 + dataL) >> 2;
	printf("Temperature raw:%d\n",(int)x);
	x = (x / 32) - 50;

	printf("Temperature:%f\n",x);

	return x;
}

float getHumidity(){
	float x;

	unsigned char command[2]= {0};

	command[0]=0x03;
	command[1]=0x01;

	printf("fd:%d\n",i2c_th02_fd);

//	wiringPiI2CWriteReg8(i2c_th02_fd, 0x03, 0x01);

	write(i2c_th02_fd,command,2);

	// Poll RDY (D0) in STATUS (register 0) until it is low (=0)
	int status = -1;
	delay (30);
	while ((status & 0x01) != 0) {
		status = wiringPiI2CReadReg8(i2c_th02_fd,0);
		printf("Status:%d\n",status);
	}

	// Read the upper and lower bytes of the temperature value from
	// DATAh and DATAl (registers 0x01 and 0x02), respectively
	unsigned char buffer[3]= {0};
    read(i2c_th02_fd, buffer, 3);

	int dataH = buffer[1] & 0xff;
	int dataL = buffer[2] & 0xff;

//	int dataH = wiringPiI2CRead(i2c_th02_fd)&0xff;
//	int dataL = wiringPiI2CRead(i2c_th02_fd)&0xff;
	printf("dataH:%02X\n",dataH);
	printf("dataL:%02X\n",dataL);

	x = (dataH * 256 + dataL) >> 4;
	printf("Humidity raw:%d\n",(int)x);
	x = (x / 16) - 24;

	printf("Humidity:%f\n",x);

	return x;
}

void runside(int side, int direction, int speed){
	// POLOLU_2756
	if (side==LEFT){
		if (direction>0) {
			digitalWrite (DIRECTION_PIN_LEFT, HIGH) ;

		} else if (direction<0) {
			digitalWrite (DIRECTION_PIN_LEFT, LOW) ;
		} else return;
		softPwmWrite (SOFT_PWM_ENGINE_LEFT, speed) ;
	} else if (side==RIGHT){
		if (direction>0) {
			digitalWrite (DIRECTION_PIN_RIGHT, HIGH) ;

		} else if (direction<0) {
			digitalWrite (DIRECTION_PIN_RIGHT, LOW) ;
		} else return;
		softPwmWrite (SOFT_PWM_ENGINE_RIGHT, speed) ;
	}

}

void go (int direction, int speed){
	runside (LEFT, direction, speed);
	runside (RIGHT, direction, speed);

	delay (DEFAULT_DELAY) ;
}

void turn (int direction, int side, int speed){
	if (side==LEFT){
//		runside (LEFT, -direction, speed);
		runside (LEFT, direction, 0);
		runside (RIGHT, direction, speed);
	}
	if (side==RIGHT){
		runside (LEFT, direction, speed);
//		runside (RIGHT, -direction,speed);
		runside (RIGHT, direction,0);
	}
	delay (DEFAULT_DELAY) ;
}


void shutdown(){
	softPwmStop(SOFT_PWM_ENGINE_LEFT) ;
	softPwmStop(SOFT_PWM_ENGINE_RIGHT) ;
}


void stop(){
	runside (LEFT, FORWARD,0);
	runside (RIGHT, FORWARD,0);
}

void toggle_light(){
	digitalWrite (FLASH_LIGHT_LED, ++led_status % 2) ;
}
