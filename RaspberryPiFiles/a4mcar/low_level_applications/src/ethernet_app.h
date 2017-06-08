/*
 * Copyright (c) 2017 FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - TCP Server implementation and TCP Server task in Low Level Module using XMOS xCORE-200 eXplorerKIT - Header file
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

#ifndef ETHERNET_APP_H_
#define ETHERNET_APP_H_

#include "defines.h"

// Defines
#define RX_BUFFER_SIZE 1400
#define INCOMING_PORT 15534
#define INIT_VAL -1
#define YOUSEND "You sent: "
#define ETHERNET_SMI_PHY_ADDRESS (0)
#define ETHERNET_TO_RN42_INTERFACE_COMMANDLENGTH 8

enum flag_status {TRUE=1, FALSE=0};

// Prototypes
void Task_EthernetAppTCPServer (chanend c_xtcp, client ethernet_to_cmdparser_if cmd_from_ethernet_to_override, server core_stats_if core_stats_interface_tile0,
                                                                                                               server core_stats_if core_stats_interface_tile1);
#endif /* ETHERNET_APP_H_ */
