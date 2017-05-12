/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - AR8035 PHY driving task for Ethernet communication implementation
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Contributors:
 *    This code uses the following repository as skeleton:
 *    https://github.com/Pajeh/XMOS_gigabit_tcp_reflect
 *
 * Update History:
 *
 */

#include "ar8035_phy_driver.h"
#include "core_debug.h"

/***
 *  Function Name:                Task_Ar8035_Phy_Driver
 *  Function Description :        Task that is responsible for driving AR8035 chip in order to maintain Ethernet communication
 *
 *  Argument                Type                                Description
 *  p_eth_reset             port                                Ethernet reset port
 *  smi                     client interface smi_if             SMI client interface
 *  eth                     client interface ethernet_cfg_if    Ethernet config interface
 */
[[combinable]]
void Task_Ar8035_Phy_Driver (port p_eth_reset, client interface smi_if smi, client interface ethernet_cfg_if eth)
{
    PrintCoreAndTileInformation("ar8035_phy_driver");
    ethernet_link_state_t link_state = ETHERNET_LINK_DOWN;
    //For RGMII version:
    //ethernet_speed_t link_speed = LINK_1000_MBPS_FULL_DUPLEX;
    //For Non-RGMII version:
    ethernet_speed_t link_speed = LINK_100_MBPS_FULL_DUPLEX;
    const int phy_reset_delay_ms = 1;
    const int link_poll_period_ms = 1000;
    const int phy_address = 0x4;
    timer tmr;
    int t;
    tmr :> t;
    p_eth_reset <: 0;
    delay_milliseconds(phy_reset_delay_ms);
    p_eth_reset <: 1;

    while (smi_phy_is_powered_down(smi, phy_address));
    //For RGMII version:
    //smi_configure(smi, phy_address, LINK_1000_MBPS_FULL_DUPLEX, SMI_ENABLE_AUTONEG);

    //For Non-RGMII version:
    smi_configure(smi, phy_address, LINK_100_MBPS_FULL_DUPLEX, SMI_DISABLE_AUTONEG);

    while (1) {
        select {
        case tmr when timerafter(t) :> t:
            ethernet_link_state_t new_state = smi_get_link_state(smi, phy_address);

            // Read AR8035 status register bits 15:14 to get the current link speed
            if (new_state == ETHERNET_LINK_UP) {
                link_speed = (ethernet_speed_t)(smi.read_reg(phy_address, 0x11) >> 14) & 3;
            }
            if (new_state != link_state) {
                link_state = new_state;
                eth.set_link_state(0, new_state, link_speed);
            }
            t += link_poll_period_ms * XS1_TIMER_KHZ;
            break;
        }
    }
}

