/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level Module Main Processing Task that processes driving commands over Bluetooth (UART) and Ethernet interface - Header file
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

#ifndef RN42_DRIVER_H_
#define RN42_DRIVER_H_

#include "defines.h"

// Command line buffer size
#define COMMANDLINE_BUFSIZE 8

// Update rate for the main processing task (Task_GetRemoteCommandsViaBluetooth)
#define RCCAR_STATUS_UPDATE_RATE    (50 * MILLISECOND)

// UART Related Defines
#define BAUD_RATE       115200
#define RX_BUFFER_SIZE  512

//Configure RN42 for the first time?
//#define RN42_INITIAL_CONFIG

// Prototypes
[[combinable]]
void Task_MainProcessingAndBluetoothControl(client uart_tx_if uart_tx,
                                            client uart_rx_if uart_rx,
                                            client control_if control_interface,
                                            client steering_if steering_interface,
                                            server ethernet_to_cmdparser_if cmd_from_ethernet_to_override,
                                            client lightstate_if lightstate_interface);

void WriteData (client uart_tx_if uart_tx, char data[]);
void InitializeRN42asSlave(client uart_tx_if uart_tx);
int isDigit (char digit);
int CharToDigit (char digit);
{int, int, int} ParseRCCommandString (char data[]);
int CheckIfCommandFormatIsValid (char* command);
short int GetLightStateFromCommands (int speed, int steering, int direction);


#endif /* RN42_DRIVER_H_ */
