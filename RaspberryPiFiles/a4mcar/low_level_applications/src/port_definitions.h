/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level Module Port, Clock and File Definitions for XMOS xCORE-200 eXplorerKIT
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

#ifndef PORT_DEFINITIONS_H_
#define PORT_DEFINITIONS_H_

#include "defines.h"

// UART Ports
    on tile[0] : port PortUART_TX = XS1_PORT_1N;
    on tile[0] : port PortUART_RX = XS1_PORT_1M;

// Steering Servo Related Defines
    on tile[0] : out port PortSteeringServo = XS1_PORT_1L; //J10

// Motor Speed Controller Defines
    on tile[0] : port PortMotorSpeedController = XS1_PORT_1G; //J8

// Relay Module Port for Braking
    on tile[0] : port PortBRAKEctrl = XS1_PORT_1O; //GPIO J1 connector (Tile0), Signal X0D38

// I2C Related Ports
    on tile[0] : port PortSCL = XS1_PORT_1E; //D12
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
