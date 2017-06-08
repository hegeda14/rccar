/*
 * Copyright (c) 2017 FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - TCP Server implementation and TCP Server task in Low Level Module using XMOS xCORE-200 eXplorerKIT
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

#include "ethernet_app.h"
#include <xtcp.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "string_itoa.h"
#include "core_debug.h"

/***
 *  Function Name:                Task_EthernetAppTCPServer
 *  Function Description :        This task implements a TCP server to handle a two-way communication between low level module and high level module.
 *                                High-level sends ----> a driving command to override driving behavior.
 *                                Low-level sends  ----> core usage information of Low-Level module that are retrieved by using core_stats_interface_tile0
 *                                                       and core_stats_interface_tile1
 *
 *  Argument                        Type                            Description
 *  c_xtcp                          chanend                         Channel end to communicate with the xtcp task which is responsible for implementing the TCP protocol communication
 *  cmd_from_ethernet_to_override   client ethernet_to_cmdparser_if Driving command that is to be sent through Ethernet Server is received using this interface.
 *  core_stats_interface_tile0      server core_stats_if            A server interface that is used for receiving core usage information (for Tile 0) from the task that is responsible for core monitoring.
 *  core_stats_interface_tile1      server core_stats_if            A server interface that is used for receiving core usage information (for Tile 1) from the task that is responsible for core monitoring.
 */
void Task_EthernetAppTCPServer(chanend c_xtcp, client ethernet_to_cmdparser_if cmd_from_ethernet_to_override, server core_stats_if core_stats_interface_tile0,
                                                                                                              server core_stats_if core_stats_interface_tile1)
{
      xtcp_connection_t conn;     // A temporary variable to hold connections associated with an event
      xtcp_connection_t responding_connection;    // The connection to the remote end we are responding to
      int send_flag = FALSE;  // This flag is set when the thread is in the middle of sending a response packet

      // The buffers for incoming data, outgoing responses and outgoing broadcast messages
      char rx_buffer[RX_BUFFER_SIZE];
      char tx_buffer[RX_BUFFER_SIZE];

      int response_len;   // The length of the response the thread is sending

      // Maintain track of two connections. Initially they are not initialized
      // which can be represented by setting their ID to -1
      responding_connection.id = INIT_VAL;

      // Instruct server to listen and create new connections on the incoming port
      xtcp_listen(c_xtcp, INCOMING_PORT, XTCP_PROTOCOL_TCP);

      //Core usage info
      short int core_usage_tile0[8], core_usage_tile1[8];
      int connected = 0; //Connection flag

      //Timer to delay send operation
      timer tmr;
      unsigned int time, delay = 5000 * MILLISECOND;
      tmr :> time;

      int string_ptr = 0;
      int string_ptr2 = 0;

      char str_buffer[4];

      PrintCoreAndTileInformation("Task_EthernetAppTCPServer");

      while (1)
      {
          select
          {
          case tmr when timerafter(time) :> void : // Timer event
                  if (!send_flag && connected==1)
                  {
                        //When client is connected and timer is ready, construct the tx_buffer
                        string_ptr = 0;

                        for ( int k = 0; k <= 7; k++)
                        {
                            string_ptr2 = 0;
                            itoa (core_usage_tile0[k], str_buffer, 4, 10);
                            //printf("%s ",str_buffer);

                            while (str_buffer[string_ptr2] != '\0')
                            {
                                tx_buffer[string_ptr] = str_buffer[string_ptr2];
                                string_ptr += 1;
                                string_ptr2 += 1;
                            }
                            if (k!=7)
                            {
                                tx_buffer[string_ptr] = ',';
                                string_ptr += 1;
                            }
                        }

                        tx_buffer[string_ptr] = ',';
                        string_ptr += 1;

                        for ( int k = 0; k <= 7; k++)
                        {
                            string_ptr2 = 0;
                            itoa (core_usage_tile1[k], str_buffer, 4, 10);
                            //printf("%s ",str_buffer);

                            while (str_buffer[string_ptr2] != '\0')
                            {
                                tx_buffer[string_ptr] = str_buffer[string_ptr2];
                                string_ptr += 1;
                                string_ptr2 += 1;
                            }
                            if (k!=7)
                            {
                                tx_buffer[string_ptr] = ',';
                                string_ptr += 1;
                            }
                        }

                        tx_buffer[string_ptr] = 'E';
                        string_ptr += 1;

                        //printf("%s \n",tx_buffer);
                        response_len = string_ptr;

                        //Once tx_buffer is ready, initialize TCP sending
                        xtcp_init_send(c_xtcp, conn);
                        send_flag = TRUE;

                  }
                  time += delay;
                  //printf("h\n");
                  break;

          case core_stats_interface_tile0.ShareCoreUsage (unsigned int core0, unsigned int core1, unsigned int core2, unsigned int core3, unsigned int core4, unsigned int core5, unsigned int core6, unsigned int core7):
                  //Event to receive core utilization information from core monitoring task when ready (for Tile 0)
                  core_usage_tile0[0]=core0;
                  core_usage_tile0[1]=core1;
                  core_usage_tile0[2]=core2;
                  core_usage_tile0[3]=core3;
                  core_usage_tile0[4]=core4;
                  core_usage_tile0[5]=core5;
                  core_usage_tile0[6]=core6;
                  core_usage_tile0[7]=core7;
                  break;

          case core_stats_interface_tile1.ShareCoreUsage (unsigned int core0, unsigned int core1, unsigned int core2, unsigned int core3, unsigned int core4, unsigned int core5, unsigned int core6, unsigned int core7):
                  //Event to receive core utilization information from core monitoring task when ready (for Tile 1)
                  core_usage_tile1[0]=core0;
                  core_usage_tile1[1]=core1;
                  core_usage_tile1[2]=core2;
                  core_usage_tile1[3]=core3;
                  core_usage_tile1[4]=core4;
                  core_usage_tile1[5]=core5;
                  core_usage_tile1[6]=core6;
                  core_usage_tile1[7]=core7;
                  break;

          // Respond to an event from the TCP server
          case xtcp_event(c_xtcp, conn):
              switch (conn.event)
              {
                  case XTCP_IFUP:
                  case XTCP_IFDOWN:
                      break;

                  case XTCP_NEW_CONNECTION:
                      // The tcp server is giving us a new connection.
                      // This is a new connection to the listening port
          #ifdef DEBUG
                      printstr("New connection to listening port:");
                      printintln(conn.local_port);
          #endif
                      printstr("New connection to listening port:");
                      printintln(conn.local_port);

                      //Connected flag:
                      connected = 1;
                      time += 2000 * MILLISECOND; //Delay sending a bit

                      if (responding_connection.id == INIT_VAL)
                      {
                          responding_connection = conn;
                      }
                      else
                      {printstr("Cannot handle new connection");
          #ifdef DEBUG
                          printstr("Cannot handle new connection");
          #endif
                          xtcp_close(c_xtcp, conn);
                      }
                      break;

                  case XTCP_RECV_DATA:
                      // When we get a packet in:
                      //
                      //  - fill the tx buffer
                      //  - initiate a send on that connection
                      //

                      response_len = xtcp_recv_count(c_xtcp, rx_buffer, RX_BUFFER_SIZE);
                      rx_buffer[response_len] = 0;
          #ifdef DEBUG
                      printstr("Got data: ");
                      printint(response_len);
                      printstrln(" bytes");
          #endif

                      //Send data to bluetooth command parser to override the command -optional
                      //printstrln(rx_buffer);
                      cmd_from_ethernet_to_override.SendCmd(rx_buffer, ETHERNET_TO_RN42_INTERFACE_COMMANDLENGTH);

          #ifdef DEBUG
                          printstr("Responding: ");
                          printstrln(rx_buffer);}
          #endif


                         break;

                  case XTCP_REQUEST_DATA:
                  case XTCP_RESEND_DATA:
                  case XTCP_SENT_DATA:
                              // The tcp server wants data for the reponding connection
                              if (send_flag == TRUE)
                              {
                  #ifdef DEBUG
                                  printstr("Resending data pf length ");
                                  printintln(response_len);
                  #endif
                                  xtcp_send(c_xtcp, tx_buffer, response_len);
                              }
                              else
                              {
                                  xtcp_complete_send(c_xtcp);
                              }

                              break;
                  case XTCP_TIMED_OUT:
                  case XTCP_ABORTED:
                  case XTCP_CLOSED:
          #ifdef DEBUG
                      printstr("Closed connection:");
                      printintln(conn.id);
          #endif
                      xtcp_close(c_xtcp, conn);
                      responding_connection.id = INIT_VAL;
                      send_flag = FALSE;
                      connected = 0;
                      break;

                  case XTCP_ALREADY_HANDLED:
                      break;
              }
          break;
      }
  }
}
