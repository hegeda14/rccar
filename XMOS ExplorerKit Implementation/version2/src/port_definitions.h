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
    on tile[0] : out port PortSteeringServo = XS1_PORT_1L; //J10

// Motor Speed Controller Defines
    on tile[0] : port PortMotorSpeedController = XS1_PORT_1G; //J8

// I2C Related Ports
    on tile[0] : port PortSCL = XS1_PORT_1E; // D12
    on tile[0] : port PortSDA = XS1_PORT_1F; //D13

// Light system PWM ports
    on tile[0] : port PortLightSystem_TH = XS1_PORT_1K;  //J12  P1K
    on tile[0] : port PortLightSystem_ST = XS1_PORT_1H;  //J13  P1H

// Ethernet related Ports & clocks
    // These ports are for accessing the OTP memory
    otp_ports_t otp_ports = on tile[0]: OTP_PORTS_INITIALIZER;

    rgmii_ports_t rgmii_ports = on tile[1]: RGMII_PORTS_INITIALIZER;

    port p_smi_mdio   = on tile[1]: XS1_PORT_1C;
    port p_smi_mdc    = on tile[1]: XS1_PORT_1D;
    port p_eth_reset  = on tile[1]: XS1_PORT_1N;

    port leds = on tile[0]: XS1_PORT_4F;

    clock clk = on tile[0]: XS1_CLKBLK_1;



#endif /* PORT_DEFINITIONS_H_ */
