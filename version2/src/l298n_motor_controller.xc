/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/
#include "l298n_motor_controller.h"

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
    uint32_t overall_pwm_period = L298N_OVERALL_PWM_PERIOD ; //20ms
    uint32_t on_period ;
    uint32_t off_period ;

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
                if (direction_val == FORWARD) //Forward speed 0-100 mapping to on period
                {
                    IN1 <: 1;
                    IN2 <: 0;
                }
                else if (direction_val == REVERSE) //Reverse speed 0-100 mapping to on period
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
