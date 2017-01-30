// pThread Core Affinity Pinning
// Author: M.Ozcelikors  <mozcelikors@gmail.com>

#ifndef PTHREAD_DISTRIBUTION_H_
#define PTHREAD_DISTRIBUTION_H_

//Includes needed
#include <pthread.h>
#include <iostream>
#include <stdlib.h>
#include <unistd.h>
#include <sched.h>
#include <cstdio>
#include <errno.h>

int placeThisThreadToCore(int core_id);
int placeAThreadToCore (pthread_t thread, int core_id);


#endif /* PTHREAD_DISTRIBUTION_H_ */
