/*
 * Copyright (c) 2017 FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level Module Alternative Motor Driver Task for L298N-based Motor controllers - Header file
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

#ifndef L298N_MOTOR_CONTROLLER_H_
#define L298N_MOTOR_CONTROLLER_H_

#include "defines.h"

#define L298N_OVERALL_PWM_PERIOD (20*MILLISECOND)

// Prototypes
void Task_DriveL298N_MotorController1Channel (port ENA, port IN1, port IN2, server control_if control_interface);

#endif /* L298N_MOTOR_CONTROLLER_H_ */
