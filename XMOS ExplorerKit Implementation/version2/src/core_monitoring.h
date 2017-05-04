/************************************************************************************
 * "Multi-functional Multi-core RCCAR for APP4MC-platform Demonstration"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/

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
