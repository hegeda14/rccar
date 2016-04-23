/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/


#include "rn42_driver.h"


//just a utility function
void WriteData (client uart_tx_if uart_tx, char data[])
{
    int i;
    for (i = 0 ; i < strlen(data); i++)
    {
        uart_tx.write(data[i]); //Write one byte
    }
}


void Task_GetRemoteCommandsViaBluetooth2 (client uart_tx_if uart_tx,
                                         client uart_rx_if uart_rx,
                                         client control_if control_interface,
                                         client steering_if steering_interface)
{
    char string[]= "asdasdasd";
    WriteData(uart_tx, string);
}


/***
 *  Function Name:              Task_GetRemoteCommandsViaBluetooth
 *  Function Description :      This function communicates with Bluetooth module via UART to obtain
 *                              control interface and steering_inferface values
 *
 *  Argument                Type                        Description
 *  control_interface       client control_if           Motor speed control value (high level)
 *  steering_interface      client steering_if          Steering control value (high level)
 *  uart_tx                 client uart_tx_if           UART TX Interface
 *  uart_rx                 client uart_rx_if           UART RX Interface
 */
void Task_GetRemoteCommandsViaBluetooth(client uart_tx_if uart_tx,
                                        client uart_rx_if uart_rx,
                                        client control_if control_interface,
                                        client steering_if steering_interface)
{
    //Simulation related definitions
    timer tmr2;
    unsigned int time2, delay2 = 4000 * MILLISECOND; //4sec
    int set_val = 0;
    int direction_val = REVERSE;
    int speed_val = 0;
    tmr2 :> time2;

    //Write some data
    char string[]= "$$$";
    WriteData(uart_tx, string);

    while (1) {
        [[ordered]] // Priority in event selection is as ordered below..
        select
        {
            case tmr2 when timerafter(time2) :> void : // Timer event
                steering_interface.ShareSteeringValue(set_val);
                control_interface.ShareDirectionValue(direction_val);
                control_interface.ShareSpeedValue(speed_val);
                time2 += delay2;

                //Toggle to other set value for testing
                if(set_val == 0)
                {
                    set_val = 50;
                    speed_val = 0;
                }
                else if(set_val == 50)
                {
                    set_val = 0;
                    speed_val = 30;
                }

                break;

            case uart_rx.data_ready(): //Read when data is available
                uint8_t data = uart_rx.read();
                printf("Data received: %d\n", data);
                break;
        }
    }
}
