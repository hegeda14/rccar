/*
 * Copyright (c) 2017 FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level Module Servo Motor driver task for steering
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

#include "servo.h"
#include "core_debug.h"

/***
 *  Function Name:              Task_ApplyPWMTo1BitPort
 *  Function Description :      This function can be used to apply PWM signal to a 1-bit port.
 *                              The default period can be changed by the variable overall_pwm_period,
 *                              keeping in mind that 100MHz clock results that 100000 timer ticks,
 *                              which means 1 millisecond.
 *
 *  Argument       Type           Description
 *  p              port           1-bit port to have pwm output
 *  duty_cycle     int            duty cycle percentage (0-100)
 */
// The following function is not used in our application, but is created as a pwm reference
void Task_ApplyPWMTo1BitPort (port p, int duty_cycle)
{
    uint32_t overall_pwm_period = 20 * MILLISECOND;
    uint32_t on_period  =   (duty_cycle * overall_pwm_period * (1.0/100));
    uint32_t off_period =   overall_pwm_period - on_period;

    //Uncomment to following to debug calculated periods
    //debug_printf("%d %d", on_period, off_period);

    uint32_t    time;
    int         port_state = 0;
    timer       tmr;

    tmr :> time;

    while(1)
    {
        select
        {
            case tmr when timerafter(time) :> void :
                //Port toggling to create PWM output
                if(port_state == 0)
                {
                    p <: 1;
                    port_state = 1;
                    time += on_period; //Extend timer deadline
                }
                else if(port_state == 1)
                {
                    p <: 0;
                    port_state = 0;
                    time += off_period; //Extend timer deadline
                }

                break;
        }
    }
}

/***
 *  Function Name:              Task_SteeringServo_MotorController
 *  Function Description :      Generates the appropriote PWM to the servo to drive it.
 *
 *  Argument            Type           Description
 *  p                   out port       1-bit port to have pwm output
 *  steering_interface  steering_if    Steering of the A4MCAR: 0-> MOST RIGHT  50-> MIDDLE  99-> MOST LEFT
 */
[[combinable]]
void Task_SteeringServo_MotorController (out port p, server steering_if steering_interface)
{
    uint32_t overall_pwm_period = STEERINGSERVO_PWM_PERIOD;
    uint32_t on_period;
    uint32_t off_period;

    uint32_t time;
    int port_state = 0;
    timer tmr;

    int steering;

    PrintCoreAndTileInformation("Task_SteeringServo_MotorController");

    // Timing measurement/debugging related definitions
    timer debug_timer;
    uint32_t start_time, end_time;

    while (1)
    {
        select
        {
            //Wait for the steering value
            case steering_interface.ShareSteeringValue (int steering_val):
                steering = steering_val;
                break;

            //Calculate PWM periods and apply period within the timer
            case tmr when timerafter(time) :> void :
                //Measure start time
                ////debug_timer :> start_time;

                tmr :> time;

                if  (steering == 0)
                {
                    on_period = STEERINGSERVO_PWM_MAXRIGHT_PULSE_WIDTH;
                }
                else if (steering > 100)
                {
                    on_period = STEERINGSERVO_PWM_MAXLEFT_PULSE_WIDTH;
                }
                else
                {
                    on_period = (STEERINGSERVO_PWM_MAXRIGHT_PULSE_WIDTH - ((STEERINGSERVO_PWM_MAXRIGHT_PULSE_WIDTH - STEERINGSERVO_PWM_MAXLEFT_PULSE_WIDTH) * (steering/100.0)));
                }

                off_period = overall_pwm_period - on_period;

                //Port Toggling for PWM output
                if(port_state == 0)
                {
                    p <: 1;
                    port_state = 1;
                    time += on_period; //Extend timer deadline
                }
                else if(port_state == 1)
                {
                    p <: 0;
                    port_state = 0;
                    time += off_period; //Extend timer deadline
                }

                //Measure end time
                ////debug_timer :> end_time;
                ////printf("SERVO t: %u", end_time - start_time);

                break;

        }
    }
}
