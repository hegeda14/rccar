/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level Module Motor controller task for TBLE02-S motor driver
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

#include "tble02s_motor_controller.h"
#include "core_debug.h"

/***
 *  Function Name:              Task_DriveTBLE02S_MotorController
 *  Function Description :      Generates the appropriote PWM to the motors to drive the TBLE02-S motor driver
 *                              and manages braking in certain conditions.
 *
 *  Argument            Type           Description
 *  p                   port           1-bit port for PWM output
 *  brake_port          port           1-bit port to control braking relay
 *  control_interface   server         Interface that can receive direction and speed
 *                                     direction:  int  FORWARD (0) or REVERSE (1)
 *                                     speed:      int  0-100
 *  control_interface   server         Interface that can receive distance values from sonar sensors
 */
[[combinable]]
void Task_DriveTBLE02S_MotorController (port p, port brake_port, server control_if control_interface, server distancesensor_if sensors_interface)
{
    uint32_t overall_pwm_period = TBLE02S_PWM_PERIOD ;
    uint32_t on_period ;
    uint32_t off_period ;

    uint8_t left, right, front, rear;
    uint8_t front_old_old, front_old, front_avg;
    uint8_t rear_old_old, rear_old, rear_avg;

    uint32_t    time;
    int         port_state = 0;
    timer       tmr;

    int direction_val = FORWARD;
    int speed_val = 0;

    PrintCoreAndTileInformation("Task_DriveTBLE02S_MotorController");

    // Timing measurement/debugging related definitions
    timer debug_timer;
    uint32_t start_time, end_time;

    while(1)
    {
        select
        {
            //Wait for the sensor values
            case sensors_interface.ShareDistanceSensorValues (uint8_t left_sensor_value,
                                                              uint8_t right_sensor_value,
                                                              uint8_t front_sensor_value,
                                                              uint8_t rear_sensor_value):
                front_old_old = front_old;
                front_old = front;
                rear_old_old = rear_old;
                rear_old = rear;
                left = left_sensor_value;
                right = right_sensor_value;
                front = front_sensor_value;
                rear = rear_sensor_value;

                front_avg = (front_old_old + front_old + front) / 3;
                rear_avg = (rear_old_old + rear_old + rear) / 3;

                //Brake if any object is seen by the front sensor
                if ( direction_val == FORWARD && front_avg > 0 && front_avg < MIN_SAFE_DISTANCE)
                {
                    brake_port <: 0;
                }

                //Brake if any object is seen by the rear sensor
                if ( direction_val == REVERSE && rear_avg > 0 && rear_avg < MIN_SAFE_DISTANCE)
                {
                    brake_port <: 0;
                }

                //debug_printf("%d %d\n", front_avg, rear_avg);


                break;

            //Wait for the direction value
            case control_interface.ShareDirectionValue (int direction):
                direction_val = direction;
                break;

            //Wait for the speed value
            case control_interface.ShareSpeedValue (int speed):
                speed_val = speed;

                //Control relays using brake_port when the speed is too low and it is time to hit the brakes
                if (speed_val < 5)
                {
                    brake_port <: 0;
                }
                else
                {
                    brake_port <: 1;
                }
                break;

            //Calculate PWM periods and apply period within the timer
            case tmr when timerafter(time) :> void :
                //Measure start time
                ////debug_timer :> start_time;

                tmr :> time;

                if (direction_val == FORWARD) //Determination of the pulse width ON period when the direction is FORWARD
                {

                   if (speed_val == 0)
                   {
                       on_period = TBLE02S_FWD_MINSPEED_PULSE_WIDTH;
                   }
                   else if (speed_val > 99)
                   {
                       on_period = TBLE02S_FWD_MAXSPEED_PULSE_WIDTH;
                   }
                   else
                   {
                       on_period = (TBLE02S_FWD_MINSPEED_PULSE_WIDTH - ((TBLE02S_FWD_MINSPEED_PULSE_WIDTH - TBLE02S_FWD_MAXSPEED_PULSE_WIDTH) * (speed_val/100.0)));
                       //printf("on_period : %d", on_period);
                   }

                   off_period = overall_pwm_period - on_period;
                }
                else if (direction_val == REVERSE) //Determination of the pulse width ON period when the direction is REVERSE
                {

                   if (speed_val == 0)
                   {
                       on_period = TBLE02S_REV_MINSPEED_PULSE_WIDTH;
                   }
                   else if (speed_val > 99)
                   {
                       on_period = TBLE02S_REV_MAXSPEED_PULSE_WIDTH;
                   }
                   else
                   {
                       on_period = (TBLE02S_REV_MINSPEED_PULSE_WIDTH + ((TBLE02S_REV_MAXSPEED_PULSE_WIDTH - TBLE02S_REV_MINSPEED_PULSE_WIDTH) * (speed_val/100.0)));
                       //printf("on_period : %d", on_period);
                   }

                   off_period = overall_pwm_period - on_period;
                }

                //Port Toggling to produce PWM signal
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
                ////printf("TBLE t: %u", end_time - start_time);

                break;
        }
    }
}
