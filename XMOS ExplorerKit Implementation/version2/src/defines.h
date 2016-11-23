/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/

#ifndef DEFINES_H_
#define DEFINES_H_

#include <xs1.h>
#include <platform.h>
#include <gpio.h>
#include "debug_print.h"
#include <print.h>
#include <string.h>
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <uart.h>
#include <i2c.h>
#include <xtcp.h>

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
    void ShareCoreUsage (short int core0, short int core1, short int core2, short int core3, short int core4, short int core5, short int core6, short int core7);
} core_stats_if;

typedef interface lightstate_if
{
    void ShareLightSystemState (short int state);
} lightstate_if;
//------------------------------------------------------Interface Definitions----




#endif /* DEFINES_H_ */
