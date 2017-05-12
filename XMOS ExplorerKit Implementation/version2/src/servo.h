/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level Module Servo Motor driver task for steering - Header file
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

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
