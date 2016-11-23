/*
 *  Hinderniserkennung+Parken.xc
 *
 *  Created on: 22.12.2015
 *  Author: Lars Waldikowski
 *
 * Steuerung des RC-Cars über Bluetooth, Lichtansteuerung, Ultraschall, Einparken
 *
 */


#include "uart_rx.h"
#include "uart_tx.h"

#include <i2c.h>
#include <string.h>
#include <platform.h>
#include <xs1.h>
#include <print.h>
#include <stdio.h>

#include "pwm.h"
#include "distance.h"
#include "app_manager.h"
#include "process_data.h"
#include "light_control.h"



#define I2C_NO_REGISTER_ADDRESS 1
#define Tile0  0
#define Tile1  1


on stdcore[Tile1]: buffered in port:1   p_rx        =   XS1_PORT_1G;
on stdcore[Tile1]: out port             p_tx        =   XS1_PORT_1C;
on stdcore[Tile0]: port                 p_button1   =   XS1_PORT_4C;
on stdcore[Tile1]: out port             p_led       =   XS1_PORT_4A;            //  Lichteinheit
on stdcore[Tile1]: out port             p_pwm       =   XS1_PORT_4B;            //  Speed an P2 15 - Control an P2 16
on stdcore[Tile1]: struct               r_i2c i2cOne = {
                                          XS1_PORT_1F,
                                          XS1_PORT_1B,
                                          1000
                                         };


#define ARRAY_SIZE(x) (sizeof(x)/sizeof(x[0]))
unsigned char tx_buffer[64];
unsigned char rx_buffer[64];
#pragma unsafe arrays
#define BAUD_RATE 115200

int main()
{
    chan c_chanTX, c_chanRX,c_process,c_end, c_right, c_left, c_front, c_back, c_light, c_control, c_speed;

      par  // parallel ausgeführte Funktionen
      {
        on stdcore[Tile1] : pwm(c_control ,c_speed);
        on stdcore[Tile1] : distance(c_right, c_left, c_front, c_back);
        on stdcore[Tile1] : uart_rx(p_rx, rx_buffer, ARRAY_SIZE(rx_buffer), BAUD_RATE, 8, UART_TX_PARITY_NONE, 1, c_chanRX);
        on stdcore[Tile1] : uart_tx(p_tx, tx_buffer, ARRAY_SIZE(tx_buffer), BAUD_RATE, 8, UART_TX_PARITY_NONE, 1, c_chanTX);
        on stdcore[Tile1] : app_manager(c_chanTX, c_chanRX, c_process,c_end,  c_control , c_speed, c_right, c_left, c_front, c_back, c_light);
        on stdcore[Tile0] : process_data(c_process, c_end);
        on stdcore[Tile1] : light_control(c_light);
      }
      return 0;
}

















