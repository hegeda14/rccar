/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - This file includes Ethernet IP configuration and OTP memory access port
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Contributors:
 *    This code uses the following repository as skeleton:
 *    https://github.com/Pajeh/XMOS_gigabit_tcp_reflect
 *
 * Update History:
 *
 */

#ifndef ETHERNET_CONFIG_H_
#define ETHERNET_CONFIG_H_

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

// IP Configuration of the Ethernet device
// To set a dynamic IP:
xtcp_ipconfig_t ipconfig = {
        {192,168,20,60}, // ip address (eg 192,168,0,2)
        {255,255,255,0}, // netmask (eg 255,255,255,0)
        {192,168,20,1}   // gateway (eg 192,168,0,1)
};

// To set a static IP, leave everything as 0:
//xtcp_ipconfig_t ipconfig = {
//        { 0, 0, 0, 0 }, // ip address (eg 192,168,0,2)
//        { 0, 0, 0, 0 }, // netmask (eg 255,255,255,0)
//        { 0, 0, 0, 0 }  // gateway (eg 192,168,0,1)
//};


#endif /* ETHERNET_CONFIG_H_ */
