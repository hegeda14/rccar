
#ifndef ROVER_TEST_TASK_H_
#define ROVER_TEST_TASK_H_

//Includes needed
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>
#include <sched.h>
#include <stdio.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>

#include "../api/basic_psys_rover.h"
#include "../interfaces.h"
#include "../RaspberryTest.h"

void *Rover_Test_Task(void *unused);
void say(char *text);
void autopark() ;
void getDistanceTrain(int channel,int rounds);


#endif /* ROVER_TEST_TASK_H_ */
