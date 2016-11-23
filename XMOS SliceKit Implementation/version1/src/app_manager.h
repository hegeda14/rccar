/*
 *  app_manager.h
 *
 *  Created on: 03.12.2015
 *  Author: Lars
 */

#ifndef APP_MANAGER_H_
#define APP_MANAGER_H_


#define BAUD_RATE 115200


void process_data(chanend c_process, chanend c_end);
void uart_tx_string(chanend c_uartTX, unsigned char message[100]);
void app_manager(chanend c_uartTX,chanend c_uartRX, chanend c_process, chanend c_end,  chanend c_control ,  chanend c_speed, chanend c_right, chanend c_left, chanend c_front, chanend c_back,chanend c_light);


#endif /* APP_MANAGER_H_ */
