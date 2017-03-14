#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <pigpio.h>

#include <unistd.h>
#include <string.h>

#define CLOSEBUTTON_PIN 21

void SetupGpio (void)
{
	gpioInitialise();
	gpioSetMode (CLOSEBUTTON_PIN, PI_INPUT);
	gpioSetMode (20, PI_OUTPUT);
	gpioWrite(20, 1);
}


void SafeShutdownCheckGpio(void)
{
	printf("%d\n", gpioRead(CLOSEBUTTON_PIN));
	if(gpioRead(CLOSEBUTTON_PIN)!=1)
	{
		//Exit system safely
		system("halt");
	}
}

int main(int argc, char *argv[])
{


    SetupGpio();

    while(1){
	SafeShutdownCheckGpio();
    }

    return 0;

}

