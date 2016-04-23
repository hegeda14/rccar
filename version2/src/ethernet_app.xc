/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/

#include "ethernet_app.h"
#include <xtcp.h>

/** Simple UDP reflection thread.
 *
 * This thread does two things:
 *
 *   - Reponds to incoming packets on port INCOMING_PORT and
 *     with a packet with the same content back to the sender.
 *   - Periodically sends out a fixed packet to a broadcast IP address.
 *
 */
void Task_EthernetAppUDPServer(chanend c_xtcp)
{
  xtcp_connection_t conn;  // A temporary variable to hold
                           // connections associated with an event
  xtcp_connection_t responding_connection; // The connection to the remote end
                                           // we are responding to
  xtcp_connection_t broadcast_connection; // The connection out to the broadcast
                                          // address
  xtcp_ipaddr_t broadcast_addr = BROADCAST_ADDR;
  int send_flag = FALSE;  // This flag is set when the thread is in the
                      // middle of sending a response packet
  int broadcast_send_flag = FALSE; // This flag is set when the thread is in the
                               // middle of sending a broadcast packet
  timer tmr;
  unsigned int time;

  // The buffers for incoming data, outgoing responses and outgoing broadcast
  // messages
  char rx_buffer[RX_BUFFER_SIZE];
  char tx_buffer[RX_BUFFER_SIZE];
  char broadcast_buffer[RX_BUFFER_SIZE] = BROADCAST_MSG;

  int response_len;  // The length of the response the thread is sending
  int broadcast_len; // The length of the broadcast message the thread is
                     // sending


  // Maintain track of two connections. Initially they are not initialized
  // which can be represented by setting their ID to -1
  responding_connection.id = INIT_VAL;
  broadcast_connection.id = INIT_VAL;

  // Instruct server to listen and create new connections on the incoming port
  xtcp_listen(c_xtcp, INCOMING_PORT, XTCP_PROTOCOL_UDP);

  tmr :> time;
  while (1) {
    select {

    // Respond to an event from the tcp server
    case xtcp_event(c_xtcp, conn):
      switch (conn.event)
        {
        case XTCP_IFUP:
          // When the interface goes up, set up the broadcast connection.
          // This connection will persist while the interface is up
          // and is only used for outgoing broadcast messages
          xtcp_connect(c_xtcp,
                       BROADCAST_PORT,
                       broadcast_addr,
                       XTCP_PROTOCOL_UDP);
          break;

        case XTCP_IFDOWN:
          // Tidy up and close any connections we have open
          if (responding_connection.id != INIT_VAL) {
            xtcp_close(c_xtcp, responding_connection);
            responding_connection.id = INIT_VAL;
          }
          if (broadcast_connection.id != INIT_VAL) {
            xtcp_close(c_xtcp, broadcast_connection);
            broadcast_connection.id = INIT_VAL;
          }
          break;

        case XTCP_NEW_CONNECTION:

          // The tcp server is giving us a new connection.
          // It is either a remote host connecting on the listening port
          // or the broadcast connection the threads asked for with
          // the xtcp_connect() call
          if (XTCP_IPADDR_CMP(conn.remote_addr, broadcast_addr)) {
            // This is the broadcast connection
            printstr("New broadcast connection established:");
            printintln(conn.id);
            broadcast_connection = conn;
         }
          else {
            // This is a new connection to the listening port
            printstr("New connection to listening port:");
            printintln(conn.local_port);
            if (responding_connection.id == INIT_VAL) {
              responding_connection = conn;
            }
            else {
              printstr("Cannot handle new connection");
              xtcp_close(c_xtcp, conn);
            }
          }
          break;

        case XTCP_RECV_DATA:
          // When we get a packet in:
          //
          //  - fill the tx buffer
          //  - initiate a send on that connection
          //
          response_len = xtcp_recv_count(c_xtcp, rx_buffer, RX_BUFFER_SIZE);
          printstr("Got data: ");
          printint(response_len);
          printstrln(" bytes");

          for (int i=0;i<response_len;i++)
            tx_buffer[i] = rx_buffer[i];

          if (!send_flag) {
            xtcp_init_send(c_xtcp, conn);
            send_flag = TRUE;
            printstrln("Responding");
          }
          else {
            // Cannot respond here since the send buffer is being used
          }
          break;

      case XTCP_REQUEST_DATA:
      case XTCP_RESEND_DATA:
        // The tcp server wants data, this may be for the broadcast connection
        // or the reponding connection

        if (conn.id == broadcast_connection.id) {
          xtcp_send(c_xtcp, broadcast_buffer, broadcast_len);
        }
        else {
          xtcp_send(c_xtcp, tx_buffer, response_len);
        }
        break;

      case XTCP_SENT_DATA:
        xtcp_complete_send(c_xtcp);
        if (conn.id == broadcast_connection.id) {
          // When a broadcast message send is complete the connection is kept
          // open for the next one
          printstrln("Sent Broadcast");
          broadcast_send_flag = FALSE;
        }
        else {
          // When a reponse is sent, the connection is closed opening up
          // for another new connection on the listening port
          printstrln("Sent Response");
          xtcp_close(c_xtcp, conn);
          responding_connection.id = INIT_VAL;
          send_flag = FALSE;
        }
        break;

      case XTCP_TIMED_OUT:
      case XTCP_ABORTED:
      case XTCP_CLOSED:
        printstr("Closed connection:");
        printintln(conn.id);
        break;

      case XTCP_ALREADY_HANDLED:
          break;
      }
      break;

    // This is the periodic case, it occurs every BROADCAST_INTERVAL
    // timer ticks
    case tmr when timerafter(time + BROADCAST_INTERVAL) :> void:

      // A broadcast message can be sent if the connection is established
      // and one is not already being sent on that connection
      if (broadcast_connection.id != INIT_VAL && !broadcast_send_flag)  {
        printstrln("Sending broadcast message");
        broadcast_len = strlen(broadcast_buffer);
        xtcp_init_send(c_xtcp, broadcast_connection);
        broadcast_send_flag = TRUE;
      }
      tmr :> time;
      break;
    }
  }
}
