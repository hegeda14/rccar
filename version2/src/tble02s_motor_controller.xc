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
void Task_DriveTBLE02S_MotorController (port p, server control_if control_interface)
{
    uint32_t overall_pwm_period = TBLE02S_PWM_PERIOD ; //20ms
    uint32_t on_period ;
    uint32_t off_period ;

    uint32_t    time;
    int         port_state = 0;
    timer       tmr;

    int direction_val = FORWARD;
    int speed_val = 0;

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
                tmr :> time;

                if (direction_val == FORWARD) //Forward speed 0-100 mapping to on period
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

                break;
        }
    }
}
