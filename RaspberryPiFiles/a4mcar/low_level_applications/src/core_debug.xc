/*
 * Copyright (c) 2017 FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level module function responsible for debugging the ID of tile and core for a function
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

#include "defines.h"
#include "core_debug.h"

/***
 *  Function Name:                PrintCoreAndTileInformation
 *  Function Description :        Low-level module function responsible for debugging the ID of tile and core for a function
 *                                This function must be called inside a task to debug its logical core ID and tile ID
 *
 *  Argument                Type                Description
 *  Function_Name           char *              Function name to debug
 */
int PrintCoreAndTileInformation (char * Function_Name)
{
    debug_printf("Starting %s task on core ID %d on tile %x\n", Function_Name,
                                                                get_logical_core_id(),
                                                                get_local_tile_id());
    return 1;
}
