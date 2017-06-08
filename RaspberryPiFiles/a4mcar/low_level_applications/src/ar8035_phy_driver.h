/*
 * Copyright (c) 2017 FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - AR8035 PHY driving task for Ethernet communication implementation - Header file
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

#ifndef AR8035_PHY_DRIVER_H_
#define AR8035_PHY_DRIVER_H_

#include "defines.h"

[[combinable]]
 void Task_Ar8035_Phy_Driver (port p_eth_reset, client interface smi_if smi, client interface ethernet_cfg_if eth);

#endif /* AR8035_PHY_DRIVER_H_ */
