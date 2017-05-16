/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Timing and performance related definitions and interfaces for the Low-level module
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

#ifndef DEFINES_H_
#define DEFINES_H_

#include <xs1.h>
#include <platform.h>
#include <gpio.h>

#include <print.h>
#include <string.h>
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <uart.h>
#include <i2c.h>
#include <xtcp.h>
#include <debug_print.h>


// Defines ---------------------------------------------------------------------

#define MICROSECOND             (XS1_TIMER_HZ / 1000000)
#define MILLISECOND             (1000 * MICROSECOND)

#pragma unsafe arrays

#define FORWARD     0
#define REVERSE     1
// ------------------------------------------------------------------Defines-----


// Interface Definitions --------------------------------------------------------
typedef interface distancesensor_if
{
    void ShareDistanceSensorValues (uint8_t left_sensor_value,
                                    uint8_t right_sensor_value,
                                    uint8_t front_sensor_value,
                                    uint8_t rear_sensor_value);
} distancesensor_if;

typedef interface control_if
{
    void ShareDirectionValue (int direction);
    void ShareSpeedValue (int speed_value);
} control_if;

typedef interface steering_if
{
    void ShareSteeringValue (int  steering_val);
} steering_if;

typedef interface ethernet_to_cmdparser_if
{
    void SendCmd (char* override_command, int cmd_length);
} ethernet_to_cmdparser_if;

typedef interface core_stats_if
{
    void ShareCoreUsage (unsigned int core0, unsigned int core1, unsigned int core2, unsigned int core3, unsigned int core4, unsigned int core5, unsigned int core6, unsigned int core7);
} core_stats_if;

typedef interface lightstate_if
{
    void ShareLightSystemState (short int state);
} lightstate_if;
//------------------------------------------------------Interface Definitions----


#endif /* DEFINES_H_ */
