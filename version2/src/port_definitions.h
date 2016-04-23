/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/

#ifndef PORT_DEFINITIONS_H_
#define PORT_DEFINITIONS_H_

//This file includes ports, clocks, and main file definitions.

#include "defines.h"

// UART Ports
    on tile[0] : port PortUART_TX = XS1_PORT_1N;
    on tile[0] : port PortUART_RX = XS1_PORT_1M;

// Steering Servo Related Defines
    on tile[0] : out port PortSteeringServo = XS1_PORT_1H; //J13

// Motor Speed Controller Defines
    on tile[0] : port PortMotorSpeedController = XS1_PORT_1K; //J12

// I2C Related Ports
    on tile[0] : port PortSCL = XS1_PORT_1E;
    on tile[0] : port PortSDA = XS1_PORT_1F;

// Ethernet related Ports & clocks
    port p_eth_rxclk  = on tile[1]: XS1_PORT_1J;
    port p_eth_rxd    = on tile[1]: XS1_PORT_4E;
    port p_eth_txd    = on tile[1]: XS1_PORT_4F;
    port p_eth_rxdv   = on tile[1]: XS1_PORT_1K;
    port p_eth_txen   = on tile[1]: XS1_PORT_1L;
    port p_eth_txclk  = on tile[1]: XS1_PORT_1I;
    port p_eth_int    = on tile[1]: XS1_PORT_1O;
    port p_eth_rxerr  = on tile[1]: XS1_PORT_1P;
    port p_eth_timing = on tile[1]: XS1_PORT_8C;

    clock eth_rxclk   = on tile[1]: XS1_CLKBLK_1;
    clock eth_txclk   = on tile[1]: XS1_CLKBLK_2;

    port p_smi_mdio = on tile[1]: XS1_PORT_1M;
    port p_smi_mdc  = on tile[1]: XS1_PORT_1N;

    // These ports are for accessing the OTP memory
    otp_ports_t otp_ports = on tile[1]: OTP_PORTS_INITIALIZER;

    xtcp_ipconfig_t ipconfig = {
            { 0, 0, 0, 0 }, // ip address (eg 192,168,0,2)
            { 0, 0, 0, 0 }, // netmask (eg 255,255,255,0)
            { 0, 0, 0, 0 } // gateway (eg 192,168,0,1)
    };




#endif /* PORT_DEFINITIONS_H_ */
