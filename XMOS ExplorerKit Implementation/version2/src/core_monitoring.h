/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level module task which is responsible for monitoring xCORE-200 eXplorerKIT cores in a tile by polling registers - Header file
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Contributors:
 *    Suggestions from the following XCORE thread are applied:
 *      https://www.xcore.com/viewtopic.php?f=26&t=5017
 *
 * Update History:
 *
 */

#ifndef CORE_MONITORING_H_
#define CORE_MONITORING_H_

#include "defines.h"

//Defines for monitoring cores
#define ONE_MS_TICKS 100000
#define POLLING_MS  (1 * ONE_MS_TICKS) // XS1_TIMER_HZ // 1250
#define PRINT_MS (1000 * ONE_MS_TICKS)

//Uncomment below preprocessor definition to see core usages in much more high precision and in floating point form.
//#define FLOATING_POINT_SHOW

//Prototypes
//[[combinable]]
void Task_MonitorCoresInATile(client core_stats_if core_stats_interface);

#endif /* CORE_MONITORING_H_ */
