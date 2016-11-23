/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/

#include "tble02s_motor_controller.h"

/***
 *  Function Name:              Task_DriveTBLE02S_MotorController
 *  Function Description :      Generates the appropriote PWM to the motors to drive the TBLE02S Motor
 *
 *  Argument       Type           Description
 *  p              port           1-bit port to have pwm output
 *  control_interface             direction + speed
 *  direction      int            FORWARD (0) or REVERSE (1)
 *  speed          int            0-100
 */
[[combinable]]
void Task_DriveTBLE02S_MotorController (port p, server control_if control_interface, server distancesensor_if sensors_interface)
{
    uint32_t overall_pwm_period = TBLE02S_PWM_PERIOD ; //20ms
    uint32_t on_period ;
    uint32_t off_period ;

    uint8_t left, right, front, rear;
    uint8_t front_old_old, front_old, front_avg;

    uint32_t    time;
    int         port_state = 0;
    timer       tmr;

    int direction_val = FORWARD;
    int speed_val = 0;

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
                left = left_sensor_value;
                right = right_sensor_value;
                front = front_sensor_value;
                rear = rear_sensor_value;

                front_avg = (front_old_old + front_old + front) / 3;

                //printf("%d %d %d %d\n", left, right, front, rear);
                break;
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


                if (direction_val == FORWARD) //Forward speed 0-100 mapping to on period
                {
                   //Sonar sensor interference
                   if ( front_avg >= 0 && front_avg < MIN_SAFE_DISTANCE)
                   {
                       on_period = TBLE02S_FWD_MINSPEED_PULSE_WIDTH;
                   }
                   else
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
                   }
                   off_period = overall_pwm_period - on_period;
                }
                else if (direction_val == REVERSE) //Reverse speed 0-100 mapping to on period
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



                //PWM Port Toggling
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
