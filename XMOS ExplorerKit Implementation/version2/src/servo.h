/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/


#ifndef SERVO_H_
#define SERVO_H_

#include "defines.h"

#define     STEERINGSERVO_PWM_PERIOD                (20 * MILLISECOND)
#define     STEERINGSERVO_PWM_MAXLEFT_PULSE_WIDTH   (1.3 * MILLISECOND)
#define     STEERINGSERVO_PWM_MAXRIGHT_PULSE_WIDTH  (1.75 * MILLISECOND)

// Prototypes
[[combinable]]
void Task_SteeringServo_MotorController (out port p, server steering_if steering_interface);
void Task_ApplyPWMTo1BitPort (port p, int duty_cycle);

#endif /* SERVO_H_ */
