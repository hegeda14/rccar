/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level Module Light System Task - Header file
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

#ifndef LIGHT_SYSTEM_H_
#define LIGHT_SYSTEM_H_

#include "defines.h"

#define LIGHTSYSTEM_PWM_PERIOD                  (20 * MILLISECOND)

// Ports are declated in port_definitions.h
// p_TH - TH port (related to driving) for light system
// p_ST - ST port (related to steering) for light system

//Defines
#define LIGHTSYSTEM_BRAKELIGHTS_TH_PERIOD       (1.7 * MILLISECOND)
#define LIGHTSYSTEM_BRAKELIGHTS_ST_PERIOD       (1.5 * MILLISECOND)

#define LIGHTSYSTEM_RIGHTBLINK_TH_PERIOD        (1.7 * MILLISECOND)
#define LIGHTSYSTEM_RIGHTBLINK_ST_PERIOD        (1.5 * MILLISECOND)

#define LIGHTSYSTEM_LEFTBLINK_TH_PERIOD         (1.7 * MILLISECOND)
#define LIGHTSYSTEM_LEFTBLINK_ST_PERIOD         (1.5 * MILLISECOND)

#define LIGHTSYSTEM_FRONTBLINK_TH_PERIOD        (1 * MILLISECOND)
#define LIGHTSYSTEM_FRONTBLINK_ST_PERIOD        (1.5 * MILLISECOND)

#define LIGHTSYSTEM_FRONTANDBACKON_TH_PERIOD    (1.2 * MILLISECOND)
#define LIGHTSYSTEM_FRONTANDBACKON_ST_PERIOD    (1.5 * MILLISECOND)

#define LIGHTSYSTEM_WARN_TH_PERIOD              (1.5 * MILLISECOND)
#define LIGHTSYSTEM_WARN_ST_PERIOD              (1.5 * MILLISECOND)

#define LIGHTSYSTEM_PIEZO_TH_PERIOD             (1.3 * MILLISECOND)
#define LIGHTSYSTEM_PIEZO_ST_PERIOD             (2 * MILLISECOND)


//Prototypes
{uint32_t, uint32_t} GetLightSystemPeriodsFromLightState (short int lightstate);

[[combinable]]
void Task_ControlLightSystem (port p_TH, port p_ST, server lightstate_if lightstate_interface);

#endif /* LIGHT_SYSTEM_H_ */
