/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level Module Light System Task
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

#include "light_system.h"
#include "core_debug.h"

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
        case 2:     //Front and back lights ON
            on_period_TH = LIGHTSYSTEM_BRAKELIGHTS_TH_PERIOD;
            on_period_ST = LIGHTSYSTEM_BRAKELIGHTS_TH_PERIOD;
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
            on_period_TH = LIGHTSYSTEM_BRAKELIGHTS_TH_PERIOD;
            on_period_ST = LIGHTSYSTEM_BRAKELIGHTS_TH_PERIOD;
            break;

        case 0:   //Warning blink
            on_period_TH = LIGHTSYSTEM_WARN_TH_PERIOD;
            on_period_ST = LIGHTSYSTEM_WARN_ST_PERIOD;
            break;

        default: case 1:     //Front and back on  //Brake lights
            on_period_TH = LIGHTSYSTEM_BRAKELIGHTS_TH_PERIOD;
            on_period_ST = LIGHTSYSTEM_BRAKELIGHTS_ST_PERIOD;
            break;
    }

    return {on_period_TH, on_period_ST};
}

/***
 *  Function Name:              Task_ControlLightSystem
 *  Function Description :      Task that manages two channel-pwm for ports p_TH and p_ST using the state info from
 *                              lightstate_interface
 *
 *  Argument                Type                                      Description
 *  p_TH                    port                                      TH port (related to driving) for light system
 *  p_ST                    port                                      ST port (related to steering) for light system
 *  lightstate_inteface     server lightstate_if                      Lightstate server interface to receive light state information
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
    int         toggle_port_TH = 0;
    int         toggle_port_ST = 0;
    timer       tmr_TH, tmr_ST;

    short int lightstate_val;

    PrintCoreAndTileInformation("Task_ControlLightSystem");

    //Initialization for some variables
    lightstate_val = 1;
    {on_period_TH, on_period_ST} = GetLightSystemPeriodsFromLightState (lightstate_val);
    off_period_ST = overall_pwm_period - on_period_ST;
    off_period_TH = overall_pwm_period - on_period_TH;

    //printf("%d %d %d %d", on_period_TH, on_period_ST, off_period_TH, off_period_ST);

    while(1)
    {
        select
        {
            //Uncomment the following to enable Light System
            //Wait for the lightstate value (Event)
            /*case lightstate_interface.ShareLightSystemState (short int state):
                lightstate_val = state;
                //printf("lst = %d\n",lightstate_val);

                {on_period_TH, on_period_ST} = GetLightSystemPeriodsFromLightState (lightstate_val);
                //calculations
                off_period_TH = overall_pwm_period - on_period_TH;
                off_period_ST = overall_pwm_period - on_period_ST;
                break;*/


            //Port p_ST PWM Timer Event
            case tmr_ST when timerafter(time_ST) :> void :

                tmr_ST :> time_ST;

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


            //Port p_TH PWM Timer Event
            case tmr_TH when timerafter(time_TH) :> void :

                tmr_TH :> time_TH;

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



        }
    }
}
