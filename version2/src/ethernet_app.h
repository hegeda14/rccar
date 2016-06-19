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
#define INCOMING_PORT 15533
#define INIT_VAL -1
#define YOUSEND "You sent: "
#define ETHERNET_SMI_PHY_ADDRESS (0)

enum flag_status {TRUE=1, FALSE=0};

// Prototypes
void Task_EthernetAppTCPServer (chanend c_xtcp, client ethernet_to_cmdparser_if cmd_from_ethernet_to_override);

#endif /* ETHERNET_APP_H_ */
