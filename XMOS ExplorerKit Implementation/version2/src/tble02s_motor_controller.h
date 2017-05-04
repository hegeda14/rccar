/************************************************************************************
 * "Multi-functional Multi-core RCCAR for APP4MC-platform Demonstration"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/


#ifndef TBLE02S_MOTOR_CONTROLLER_H_
#define TBLE02S_MOTOR_CONTROLLER_H_

#include "defines.h"



#define TBLE02S_FWD_MINSPEED_PULSE_WIDTH    (1.47 * MILLISECOND)
#define TBLE02S_FWD_MAXSPEED_PULSE_WIDTH    (1.41 * MILLISECOND)//for max speed set to:(1.15 * MILLISECOND)
#define TBLE02S_REV_MINSPEED_PULSE_WIDTH    (1.55 * MILLISECOND)
#define TBLE02S_REV_MAXSPEED_PULSE_WIDTH    (1.67 * MILLISECOND)//for max speed set to:(1.87 * MILLISECOND)
#define TBLE02S_PWM_PERIOD                  (20 * MILLISECOND)



#define MIN_SAFE_DISTANCE               50  //cm

// Prototypes
[[combinable]]
 void Task_DriveTBLE02S_MotorController (port p, port brake_port, server control_if control_interface, server distancesensor_if sensors_interface);


#endif /* TBLE02S_MOTOR_CONTROLLER_H_ */
