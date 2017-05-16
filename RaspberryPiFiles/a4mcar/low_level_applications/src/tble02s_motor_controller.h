/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level Module Motor controller task for TBLE02-S motor driver - Header file
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

#ifndef TBLE02S_MOTOR_CONTROLLER_H_
#define TBLE02S_MOTOR_CONTROLLER_H_

#include "defines.h"

#define TBLE02S_FWD_MINSPEED_PULSE_WIDTH    (1.47 * MILLISECOND)
#define TBLE02S_FWD_MAXSPEED_PULSE_WIDTH    (1.41 * MILLISECOND)//for max speed set to:(1.15 * MILLISECOND)
#define TBLE02S_REV_MINSPEED_PULSE_WIDTH    (1.55 * MILLISECOND)
#define TBLE02S_REV_MAXSPEED_PULSE_WIDTH    (1.67 * MILLISECOND)//for max speed set to:(1.87 * MILLISECOND)
#define TBLE02S_PWM_PERIOD                  (20 * MILLISECOND)

#define MIN_SAFE_DISTANCE               40  //Distance in centimeters before RCCAR hits the brakes

// Prototypes
[[combinable]]
 void Task_DriveTBLE02S_MotorController (port p, port brake_port, server control_if control_interface, server distancesensor_if sensors_interface);


#endif /* TBLE02S_MOTOR_CONTROLLER_H_ */
