/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/

#include "light_system.h"

/***
 *  Function Name:              GetLightSystemPeriodsFromLightState
 *  Function Description :      Gets light system pwm on periods for pins p_TH and p_ST
 *
 *  Argument                Type                        Description
 *  lightstate              short int                   Light state
 *
 *  Returns : {uint32_t on_period_TH, uint32_t on_period_ST}
 */
{uint32_t, uint32_t} GetLightSystemPeriodsFromLightState (short int lightstate)
{
    uint32_t on_period_TH, on_period_ST;

    switch (lightstate)
    {
        case 1:     //Brake lights
            on_period_TH = LIGHTSYSTEM_BRAKELIGHTS_TH_PERIOD;
            on_period_ST = LIGHTSYSTEM_BRAKELIGHTS_ST_PERIOD;
            break;

        case 2:     //Front and back lights ON
            on_period_TH = LIGHTSYSTEM_FRONTANDBACKON_TH_PERIOD;
            on_period_ST = LIGHTSYSTEM_FRONTANDBACKON_ST_PERIOD;
            break;

        case 3:     //Front lights Blink
            on_period_TH = LIGHTSYSTEM_FRONTBLINK_TH_PERIOD;
            on_period_ST = LIGHTSYSTEM_FRONTBLINK_ST_PERIOD;
            break;

        case 4:     //Left lights Blink
            on_period_TH = LIGHTSYSTEM_LEFTBLINK_TH_PERIOD;
            on_period_ST = LIGHTSYSTEM_LEFTBLINK_ST_PERIOD;
            break;

        case 5:     //Right lights Blink
            on_period_TH = LIGHTSYSTEM_RIGHTBLINK_TH_PERIOD;
            on_period_ST = LIGHTSYSTEM_RIGHTBLINK_ST_PERIOD;
            break;

        case 6:     //Back-lit lights and piezo beeps
            on_period_TH = LIGHTSYSTEM_PIEZO_TH_PERIOD;
            on_period_ST = LIGHTSYSTEM_PIEZO_ST_PERIOD;
            break;

        case 0: default:  //Warning blink
            on_period_TH = LIGHTSYSTEM_WARN_TH_PERIOD;
            on_period_ST = LIGHTSYSTEM_WARN_ST_PERIOD;
            break;
    }

    return {on_period_TH, on_period_ST};
}

/***
 *  Function Name:              Task_ControlLightSystem
 *  Function Description :      Task that manages two channel-pwm for ports p_TH and p_ST using the state info from
 *                              lightstate_interface
 */
[[combinable]]
void Task_ControlLightSystem (port p_TH, port p_ST, server lightstate_if lightstate_interface)
{
    uint32_t overall_pwm_period = LIGHTSYSTEM_PWM_PERIOD ;
    uint32_t on_period_TH,  on_period_ST;
    uint32_t off_period_TH, off_period_ST;

    uint32_t    time_TH, time_ST;
    int         port_state_TH = 0;
    int         port_state_ST  = 0;
    timer       tmr_TH, tmr_ST;

    short int lightstate_val;

    //Initialization for some variables
    on_period_TH = LIGHTSYSTEM_FRONTANDBACKON_TH_PERIOD;
    on_period_ST = LIGHTSYSTEM_FRONTANDBACKON_ST_PERIOD;
    lightstate_val = 2;

    while(1)
    {
        select
        {
            //Wait for the lightstate value (Event)
            case lightstate_interface.ShareLightSystemState (short int state):
                lightstate_val = state;
                {on_period_TH, on_period_ST} = GetLightSystemPeriodsFromLightState (lightstate_val);
                break;

            //Port p_TH PWM Timer Event
            case tmr_TH when timerafter(time_TH) :> void :

                tmr_TH :> time_TH;

                //calculations

                off_period_TH = overall_pwm_period - on_period_TH;



                //PWM Port Toggling
                if(port_state_TH == 0)
                {
                    p_TH <: 1;
                    port_state_TH = 1;
                    time_TH += on_period_TH; //Extend timer deadline
                }
                else if(port_state_TH == 1)
                {
                    p_TH <: 0;
                    port_state_TH = 0;
                    time_TH += off_period_TH; //Extend timer deadline
                }

                break;


            //Port p_ST PWM Timer Event
            case tmr_ST when timerafter(time_ST) :> void :

                tmr_ST :> time_ST;

                //calculations

                off_period_ST = overall_pwm_period - on_period_ST;



                //PWM Port Toggling
                if(port_state_ST == 0)
                {
                    p_ST <: 1;
                    port_state_ST = 1;
                    time_ST += on_period_ST; //Extend timer deadline
                }
                else if(port_state_ST == 1)
                {
                    p_ST <: 0;
                    port_state_ST = 0;
                    time_ST += off_period_ST; //Extend timer deadline
                }

                break;
        }
    }
}
