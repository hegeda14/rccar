
#ifndef ROVER_TEST_TASK_H_
#define ROVER_TEST_TASK_H_

//Includes needed
#include <pthread.h>
#include <iostream>
#include <stdlib.h>
#include <unistd.h>
#include <sched.h>
#include <cstdio>
#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "basic_psys_rover.h"


void *Rover_Test_Task(void *unused);

#endif /* ROVER_TEST_TASK_H_ */
