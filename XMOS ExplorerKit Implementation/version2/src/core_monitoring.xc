/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/

#include "core_monitoring.h"

[[combinable]]
void Task_MonitorCoresInATile(client core_stats_if core_stats_interface)
{
      short int t;
      timer poll_tmr, print_tmr;
      int poll_time, print_time;
      poll_tmr :> poll_time;

      print_time = poll_time + PRINT_MS;

      short int core_busy[8];
      short int core_idle[8];
      short int core_usage[8];

      for (t = 0; t <= 7; t++) {
            core_busy[t] = 0;
            core_idle[t] = 0;
      }

      int tile_id = get_local_tile_id();

      while(1)
      {
            select {
                  case print_tmr when timerafter(print_time) :> void:
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
                                  if (core_idle[t] + core_busy[t] > 0) {
                                      core_usage[t] = (100 * core_busy[t]) / (core_busy[t] + core_idle[t]);
                                  } else {
                                      core_usage[t] = 0;
                                  }
                          }
                          core_stats_interface.ShareCoreUsage (core_usage[0],
                                                             core_usage[1],
                                                             core_usage[2],
                                                             core_usage[3],
                                                             core_usage[4],
                                                             core_usage[5],
                                                             core_usage[6],
                                                             core_usage[7]);
                        /*printf("tile[%x]: %d %d %d %d %d %d %d %d\n",tile_id, core_usage[0],
                                                        core_usage[1],
                                                        core_usage[2],
                                                        core_usage[3],
                                                        core_usage[4],
                                                        core_usage[5],
                                                        core_usage[6],
                                                        core_usage[7]);*/

                        for (t = 0; t <= 7; t++) {
                            core_busy[t] = 0;
                            core_idle[t] = 0;
                        }
                        print_time += PRINT_MS;
                        break;

                  case poll_tmr when timerafter(poll_time) :> void:
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
                        break;
            }
      }
}
