// Temperature Task
// Author: Gaël Blondelle
// Contributors: Mustafa Oezcelikoers <mozcelikors@gmail.com>
// The code uses Groove Temperature and Humidity Sensor v1.0
// Pins:
//      I2C pins in WiringPi  8 -> SDA       9 -> SCL
//      I2C pins in BCM       BCM-2 -> SDA   BCM-3 -> SCL
//      Physical I2c Pins     3 -> SDA       5 -> SCL
// Preliminaries:
//      1. sudo raspi-config > Advanced > Enable I2C and SPI
//      2. In /boot/config.txt, uncomment
//                              dtparam=i2c_arm=on
//                              dtparam=i2c=on
//                              dtparam=spi=on
//      3. Install following through apt-get:
//                              i2c-tools
//                              libi2c-dev

#include "temperature_task.h"

static int i2c_th02_fd = 0;



void setupTemperatureSensor()
{
	wiringPiSetup();
	i2c_th02_fd = wiringPiI2CSetup (0x40);
}

float getTemperatureFromSensor()
{
	float x;

	unsigned char command[2]= {0};

	command[0]=0x03;
	command[1]=0x11;

	//printf("fd:%d\n",i2c_th02_fd);

	//	wiringPiI2CWriteReg8(i2c_th02_fd, 0x03, 0x01);

	write(i2c_th02_fd,command,2);

	// Poll RDY (D0) in STATUS (register 0) until it is low (=0)
	int status = -1;
	delay (30);
	while ((status & 0x01) != 0) {
		status = wiringPiI2CReadReg8(i2c_th02_fd,0);
		//printf("Status:%d\n",status);
	}

	// Read the upper and lower bytes of the temperature value from
	// DATAh and DATAl (registers 0x01 and 0x02), respectively
	unsigned char buffer[3]= {0};
    read(i2c_th02_fd, buffer, 3);

	int dataH = buffer[1] & 0xff;
	int dataL = buffer[2] & 0xff;

	//	int dataH = wiringPiI2CRead(i2c_th02_fd)&0xff;
	//	int dataL = wiringPiI2CRead(i2c_th02_fd)&0xff;
	//printf("dataH:%02X\n",dataH);
	//printf("dataL:%02X\n",dataL);

	x = (dataH * 256 + dataL) >> 2;
	//printf("Temperature raw:%d\n",(int)x);
	x = (x / 32) - 50;

	//printf("Temperature:%f\n",x);

	return x;
}

void *Temperature_Task(void *unused)
{
	setupTemperatureSensor();
	while (1)
	{
		printf("Temperature: %f\n", getTemperatureFromSensor());
	}

	/* the function must return something - NULL will do */
	return NULL;
}
