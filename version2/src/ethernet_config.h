/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/

#ifndef ETHERNET_CONFIG_H_
#define ETHERNET_CONFIG_H_


//This file includes Ethernet IP configuration and OTP memory access port

#include "defines.h"

    // These ports are for accessing the OTP memory
    otp_ports_t otp_ports = on tile[1]: OTP_PORTS_INITIALIZER;

    xtcp_ipconfig_t ipconfig = {
            { 192, 168, 20, 60 }, // ip address (eg 192,168,0,2)
            { 255, 255, 255, 0 }, // netmask (eg 255,255,255,0)
            { 192, 168, 20, 1 }  // gateway (eg 192,168,0,1)
    };


#endif /* ETHERNET_CONFIG_H_ */
