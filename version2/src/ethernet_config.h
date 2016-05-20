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

// Defines
#define DEBUG 1
#define ETHERNET_SMI_PHY_ADDRESS (0)
#define DATAINTERFACES  5

// An enum to manage the array of connections from the ethernet component
// to its clients.
enum eth_clients {
  ETH_TO_ICMP,
  NUM_ETH_CLIENTS
};

enum cfg_clients {
  CFG_TO_ICMP,
  CFG_TO_PHY_DRIVER,
  NUM_CFG_CLIENTS
};

// IP Config - change this to suit your network.  Leave with all
// 0 values to use DHCP/AutoIP
xtcp_ipconfig_t ipconfig = {
        {192,168,1,92},//{ 0,0,0,0 }, // ip address (eg 192,168,0,2)
        {255,255,255,0},//{ 0, 0, 0, 0 }, // netmask (eg 255,255,255,0)
        {192,168,1,1}//{ 0, 0, 0, 0 } // gateway (eg 192,168,0,1)
};
//xtcp_ipconfig_t ipconfig = {
//        { 0,0,0,0 }, // ip address (eg 192,168,0,2)
//        { 0, 0, 0, 0 }, // netmask (eg 255,255,255,0)
//        { 0, 0, 0, 0 } // gateway (eg 192,168,0,1)
//};


#endif /* ETHERNET_CONFIG_H_ */
