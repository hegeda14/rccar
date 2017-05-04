/************************************************************************************
 * "Multi-functional Multi-core RCCAR for APP4MC-platform Demonstration"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/


#ifndef LIGHT_SYSTEM_H_
#define LIGHT_SYSTEM_H_

#include "defines.h"

#define LIGHTSYSTEM_PWM_PERIOD                  (20 * MILLISECOND)

// p_TH- drive light pwm pin
// p_ST- steering light pwm pin

//Defines
#define LIGHTSYSTEM_BRAKELIGHTS_TH_PERIOD       (1.7 * MILLISECOND)//(1.7 * MILLISECOND)//1.7 idi//1.3
#define LIGHTSYSTEM_BRAKELIGHTS_ST_PERIOD       (1.5 * MILLISECOND)//(1.5 * MILLISECOND)

#define LIGHTSYSTEM_RIGHTBLINK_TH_PERIOD        (1.7 * MILLISECOND)//1.3 idi
#define LIGHTSYSTEM_RIGHTBLINK_ST_PERIOD        (1.5 * MILLISECOND)

#define LIGHTSYSTEM_LEFTBLINK_TH_PERIOD         (1.7 * MILLISECOND)//1.3 idi
#define LIGHTSYSTEM_LEFTBLINK_ST_PERIOD         (1.5 * MILLISECOND)

#define LIGHTSYSTEM_FRONTBLINK_TH_PERIOD        (1 * MILLISECOND)
#define LIGHTSYSTEM_FRONTBLINK_ST_PERIOD        (1.5 * MILLISECOND)

#define LIGHTSYSTEM_FRONTANDBACKON_TH_PERIOD    (1.2 * MILLISECOND)//1.3 idi
#define LIGHTSYSTEM_FRONTANDBACKON_ST_PERIOD    (1.5 * MILLISECOND)

#define LIGHTSYSTEM_WARN_TH_PERIOD              (1.5 * MILLISECOND)
#define LIGHTSYSTEM_WARN_ST_PERIOD              (1.5 * MILLISECOND)

#define LIGHTSYSTEM_PIEZO_TH_PERIOD             (1.3 * MILLISECOND) //2.2 idi
#define LIGHTSYSTEM_PIEZO_ST_PERIOD             (2 * MILLISECOND)


//Prototypes
{uint32_t, uint32_t} GetLightSystemPeriodsFromLightState (short int lightstate);

[[combinable]]
void Task_ControlLightSystem (port p_TH, port p_ST, server lightstate_if lightstate_interface);




#endif /* LIGHT_SYSTEM_H_ */
