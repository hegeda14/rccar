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
#define RX_BUFFER_SIZE 300
#define INCOMING_PORT 15533
#define BROADCAST_INTERVAL 600000000
#define BROADCAST_PORT 15534
#define BROADCAST_ADDR {255,255,255,255}
#define BROADCAST_MSG "XMOS Broadcast\n"
#define INIT_VAL -1

#define XTCP_MII_BUFSIZE (4096)
#define ETHERNET_SMI_PHY_ADDRESS (0)

enum flag_status {TRUE=1, FALSE=0};

// Prototypes
void Task_EthernetAppUDPServer(chanend c_xtcp);

#endif /* ETHERNET_APP_H_ */
