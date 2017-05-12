/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level Module Alternative Motor Driver Task for L298N-based Motor controllers
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

#include "l298n_motor_controller.h"
#include "core_debug.h"

/***
 *  Function Name:              Task_DriveL298N_MotorController1Channel
 *  Function Description :      Generates the appropriote PWM to the motors to drive the L298N Motor Driver
 *
 *  Argument       Type           Description
 *  ENA            port           1-bit port to have pwm output (to control speed)
 *  IN1 and IN2    port           ports for direction adjustment
 *  control_interface             direction + speed
 *  direction      int            FORWARD (0) or REVERSE (1)
 *  speed          int            0-100
 */
void Task_DriveL298N_MotorController1Channel (port ENA, port IN1, port IN2, server control_if control_interface)
{
    uint32_t overall_pwm_period = L298N_OVERALL_PWM_PERIOD ;
    uint32_t on_period ;
    uint32_t off_period ;

    uint32_t    time;
    int         port_state = 0;
    timer       tmr;

    int direction_val = FORWARD;
    int speed_val = 0;

    // Timing measurement/debugging related definitions
    //timer debug_timer;
    //uint32_t start_time, end_time;

    while(1)
    {
        select
        {
            //Wait for the direction value
            case control_interface.ShareDirectionValue (int direction):
                direction_val = direction;
                break;

            //Wait for the speed value
            case control_interface.ShareSpeedValue (int speed):
                speed_val = speed;
                break;

            //Calculate PWM periods and apply period within the timer
            case tmr when timerafter(time) :> void :
                //Measure start time
                ////debug_timer :> start_time;

                tmr :> time;

                //Configure direction
                if (direction_val == FORWARD) //Forward case
                {
                    IN1 <: 1;
                    IN2 <: 0;
                }
                else if (direction_val == REVERSE) //Reverse case
                {
                    IN1 <: 0;
                    IN2 <: 1;
                }

                //Configure period to adjust speeds

                if(speed_val < 5)
                {
                    on_period = 0;
                }
                else if (speed_val > 95)
                {
                    on_period = overall_pwm_period;
                }
                else
                {
                    on_period  =   (speed_val * overall_pwm_period * (1.0/100));
                }

                off_period =   overall_pwm_period - on_period;

                //PWM Port Toggling
                if(port_state == 0)
                {
                    ENA <: 1;
                    port_state = 1;
                    time += on_period; //Extend timer deadline
                }
                else if(port_state == 1)
                {
                    ENA <: 0;
                    port_state = 0;
                    time += off_period; //Extend timer deadline
                }

                //Measure end time
                ////debug_timer :> end_time;
                ////printf("L298 t: %u", end_time - start_time);

                break;
        }
    }
}
