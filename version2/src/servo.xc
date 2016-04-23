/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/


#include "servo.h"


/***
 *  Function Name:              Task_ApplyPWMTo1BitPort
 *  Function Description :      This function can be used to apply PWM signal to a 1-bit port.
 *                              The default period can be changed by the varialbe overall_pwm_period,
 *                              keeping in mind that 100MHz clock results that 100000 timer ticks mean
 *                              1 millisecond.
 *
 *  Argument       Type           Description
 *  p              port           1-bit port to have pwm output
 *  duty_cycle     int            duty cycle percentage (0-100)
 */
// The following function is not used in our application, but is created as a pwm reference
void Task_ApplyPWMTo1BitPort (port p, int duty_cycle) // int duty_cycle later to be declared as server
{
    uint32_t overall_pwm_period = 2 * MILLISECOND; //2ms
    uint32_t on_period  =   (duty_cycle * overall_pwm_period * (1.0/100));
    uint32_t off_period =   overall_pwm_period - on_period;
    printf("%d %d", on_period, off_period);

    uint32_t    time;
    int         port_state = 0;
    timer       tmr;

    tmr :> time;

    while(1)
    {
        select
        {
            case tmr when timerafter(time) :> void :
                //Toggle
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
 *  p                   port           1-bit port to have pwm output
 *  steering_interface  steering_if    0-> MOST RIGHT  100-> MOST LEFT
 */
void Task_SteeringServo_MotorController (out port p, server steering_if steering_interface)
{
    uint32_t overall_pwm_period = STEERINGSERVO_PWM_PERIOD;
    uint32_t on_period;
    uint32_t off_period;

    uint32_t time;
    int port_state = 0;
    timer tmr;

    int steering;

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
                tmr :> time;

                if  (steering == 0)
                {
                    on_period = STEERINGSERVO_PWM_MAXLEFT_PULSE_WIDTH;
                }
                else if (steering > 100)
                {
                    on_period = STEERINGSERVO_PWM_MAXRIGHT_PULSE_WIDTH;
                }
                else
                {
                    on_period = (STEERINGSERVO_PWM_MAXLEFT_PULSE_WIDTH + ((STEERINGSERVO_PWM_MAXRIGHT_PULSE_WIDTH - STEERINGSERVO_PWM_MAXLEFT_PULSE_WIDTH) * (steering/100.0)));
                }

                off_period = overall_pwm_period - on_period;

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
