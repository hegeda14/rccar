/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/

#ifndef ETHERNET_APP_H_
#define ETHERNET_APP_H_

#include "defines.h"

// Defines
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
