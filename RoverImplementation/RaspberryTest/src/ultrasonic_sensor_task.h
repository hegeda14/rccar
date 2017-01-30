// Ultrasonic reading using wiringPi for Groove Ultrasonic Ranger
// Author: M.Ozcelikors  <mozcelikors@gmail.com>
// Migrated from Groove Ultrasonic Ranger Python version
// to C/C++

#ifndef ULTRASONIC_SENSOR_TASK_H_
#define ULTRASONIC_SENSOR_TASK_H_

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>

//Pin for SIG input
// BCM-5,  Physical 29, wiringPi 21
#define SIG 21

void *Groove_Ultrasonic_Sensor_Task(void *);
int getCM_GrooveUltrasonicRanger();
void setup_GrooveUltrasonicRanger();

#endif /* ULTRASONIC_SENSOR_TASK_H_ */
