/************************************************************************************
 * "Multi-functional Multi-core RCCAR for APP4MC-platform Demonstration"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/

#include "defines.h"
#include "core_debug.h"

int PrintCoreAndTileInformation(char * Function_Name)
{
    debug_printf("Starting %s task on core ID %d on tile %x\n", Function_Name,
                                                                get_logical_core_id(),
                                                                get_local_tile_id());
    return 1;
}
