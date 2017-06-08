/*
 * Copyright (c) 2017 FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level module task which is responsible for monitoring xCORE-200 eXplorerKIT cores in a tile by polling registers
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

#include "core_monitoring.h"
#include <debug_print.h>
#include "core_debug.h"

/***
 *  Function Name:                Task_MonitorCoresInATile
 *  Function Description :        Low-level module task which is responsible for monitoring xCORE-200 eXplorerKIT cores in a tile by polling registers
 *                                This function monitors the tile at which it is placed on
 *
 *  Argument                        Type                            Description
 *  core_stats_interface            client core_stats_if            A client interface that is used for sending core usage information for cores 0 through 7 of the respective tile
 */
//[[combinable]]
void Task_MonitorCoresInATile(client core_stats_if core_stats_interface)
{
      short int t;
      timer poll_tmr, print_tmr;
      int poll_time, print_time;
      poll_tmr :> poll_time;

      print_time = poll_time + PRINT_MS;

      unsigned int core_busy[8];
      unsigned int core_idle[8];
      unsigned int core_usage[8];
      float core_usage_f[8];

      for (t = 0; t <= 7; t++) {
            core_busy[t] = 0;
            core_idle[t] = 0;
      }

      int tile_id = get_local_tile_id();
      int cntr = 0;

      PrintCoreAndTileInformation("Task_MonitorCoresInATile");

      while(1)
      {
            select {
                  case print_tmr when timerafter(print_time) :> void:
                        // To debug;
                        /*printf("tile[%x]: %d/%d %d/%d %d/%d %d/%d %d/%d %d/%d %d/%d %d/%d\n",
                            tile_id,
                            core_busy[0], core_idle[0],
                            core_busy[1], core_idle[1],
                            core_busy[2], core_idle[2],
                            core_busy[3], core_idle[3],
                            core_busy[4], core_idle[4],
                            core_busy[5], core_idle[5],
                            core_busy[6], core_idle[6],
                            core_busy[7], core_idle[7]);*/
                          for (t = 0; t <= 7; t++) {
                                  int numerator = (core_busy[t] * 100);
                                  int denominator = (core_idle[t] + core_busy[t]);

                                  if (denominator) {
                                      core_usage[t] = core_usage[t] + numerator / denominator;
                                  } else {
                                      core_usage[t] = core_usage[t] + 0;
                                  }

#ifdef FLOATING_POINT_SHOW
                                  float numerator_f = (core_busy[t] * 100.0f);
                                  float denominator_f = (core_idle[t] + core_busy[t]);
                                  if (denominator_f) {
                                      core_usage_f[t] = core_usage_f[t] + numerator_f / denominator_f;

                                  } else {
                                      core_usage_f[t] = core_usage_f[t] + 0;
                                  }
#endif

                          }

                          cntr = cntr + 1;
                          if (cntr == 5)
                          {
                                  if (core_usage[0]>=0 && core_usage[0]<=500)
                                  {
                                      core_stats_interface.ShareCoreUsage (core_usage[0] /5,
                                                                         core_usage[1] /5,
                                                                         core_usage[2] /5,
                                                                         core_usage[3] /5,
                                                                         core_usage[4] /5,
                                                                         core_usage[5] /5,
                                                                         core_usage[6] /5,
                                                                         core_usage[7] /5);
                                      debug_printf("tile[%x]: %d %d %d %d %d %d %d %d\n\n",tile_id, core_usage[0] /5,
                                                                        core_usage[1] /5,
                                                                        core_usage[2] /5,
                                                                        core_usage[3] /5,
                                                                        core_usage[4] /5,
                                                                        core_usage[5] /5,
                                                                        core_usage[6] /5,
                                                                        core_usage[7] /5);
#ifdef FLOATING_POINT_SHOW
                                      for (int i = 0; i < 8; ++i) core_usage_f[i] /= 5.0f;
                                      printf("tile[%x]: %4.3f %4.3f %4.3f %4.3f %4.3f %4.3f %4.3f %4.3\n\n",tile_id, core_usage_f[0],
                                                              core_usage_f[1],
                                                              core_usage_f[2],
                                                              core_usage_f[3],
                                                              core_usage_f[4],
                                                              core_usage_f[5],
                                                              core_usage_f[6],
                                                              core_usage_f[7]);
#endif

                                      for (t = 0; t <= 7; t++) {
                                          core_usage[t] = 0;
                                          core_usage_f[t] = 0;
                                      }
                                      cntr = 0;
                                  }
                                  else
                                  {
                                        for (t = 0; t <= 7; t++) {
                                            core_usage[t] = 0;
                                            core_usage_f[t] = 0;
                                        }
                                        cntr = 0;
                                  }
                        }

                        for (t = 0; t <= 7; t++) {
                            core_busy[t] = 0;
                            core_idle[t] = 0;
                        }
                        print_time += PRINT_MS;
                        break;


                  //For maximum possible polling rate..
                  default: //case poll_tmr when timerafter(poll_time) :> void:
                        for (t = 0; t <= 7; t++) {
                              // Read the processor state
                              int ps_value = getps(0x100*t+4);

                              // Read the status register
                              unsigned int sr_value;
                              read_pswitch_reg(tile_id, XS1_PSWITCH_T0_SR_NUM+t, sr_value);

                              const int in_use = (ps_value & 0x1);
                              const int waiting = (sr_value >> 6) & 0x1;
                              if (in_use) {
                                      if (waiting) {
                                          core_idle[t] += 1;
                                      } else {
                                          core_busy[t] += 1;
                                      }
                              }

                        }
                        break;

                  //For a custom polling rate, specified in core_monitoring.h, please use following instead of default: statement
                  //that is defined above.
                  /*case poll_tmr when timerafter(poll_time) :> void:
                        for (t = 0; t <= 7; t++) {
                              // Read the processor state
                              int ps_value = getps(0x100*t+4);

                              // Read the status register
                              unsigned int sr_value;
                              read_pswitch_reg(tile_id, XS1_PSWITCH_T0_SR_NUM+t, sr_value);

                              const int in_use = (ps_value & 0x1);
                              const int waiting = (sr_value >> 6) & 0x1;
                              if (in_use) {
                                      if (waiting) {
                                          core_idle[t] += 1;
                                      } else {
                                          core_busy[t] += 1;
                                      }
                              }

                        }
                        poll_time += POLLING_MS;
                        break;*/
            }
      }
}
