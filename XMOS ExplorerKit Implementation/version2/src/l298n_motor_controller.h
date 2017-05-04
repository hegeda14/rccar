/************************************************************************************
 * "Multi-functional Multi-core RCCAR for APP4MC-platform Demonstration"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/

#ifndef L298N_MOTOR_CONTROLLER_H_
#define L298N_MOTOR_CONTROLLER_H_

#include "defines.h"


#define L298N_OVERALL_PWM_PERIOD (20*MILLISECOND)

// Prototypes
void Task_DriveL298N_MotorController1Channel (port ENA, port IN1, port IN2, server control_if control_interface);

#endif /* L298N_MOTOR_CONTROLLER_H_ */
