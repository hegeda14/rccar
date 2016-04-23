/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/

#ifndef RN42_DRIVER_H_
#define RN42_DRIVER_H_

#include "defines.h"


// UART Related Defines
#define BAUD_RATE       115200
#define RX_BUFFER_SIZE  64

// Prototypes
void Task_GetRemoteCommandsViaBluetooth(client uart_tx_if uart_tx,
                                        client uart_rx_if uart_rx,
                                        client control_if control_interface,
                                        client steering_if steering_interface);
void Task_GetRemoteCommandsViaBluetooth2 (client uart_tx_if uart_tx,
                                         client uart_rx_if uart_rx,
                                         client control_if control_interface,
                                         client steering_if steering_interface);
void WriteData (client uart_tx_if uart_tx, char data[]);

#endif /* RN42_DRIVER_H_ */
