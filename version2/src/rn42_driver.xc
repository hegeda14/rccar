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


/***
 *  Function Name:              WriteData
 *  Function Description :      This utility function writes a string over uart_tx.
 *
 *  Argument                Type                        Description
 *  uart_tx                 client uart_tx_if           UART TX Interface
 *  data                    char[]                      string to be sent
 */
void WriteData (client uart_tx_if uart_tx, char data[])
{
    int i;
    for (i = 0 ; i < strlen(data); i++)
    {
        uart_tx.write(data[i]); //Write one byte
    }
}

/***
 *  Function Name:              isDigit
 *  Function Description :      Checks if a character is a digit char
 *
 *  Argument                Type                        Description
 *  digit                   char                        Character to be checked
 *
 */
int isDigit (char digit)
{
    switch (digit)
    {
        case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
            return 1;
        default:
            return -1;
            break;
    }
}

/***
 *  Function Name:              CharToDigit
 *  Function Description :      Returns the decimal value digit from ASCII
 *
 *  Argument                Type                        Description
 *  digit                   char                        Character to be converted to decimal
 *
 */
int CharToDigit (char digit)
{
    return digit - '0';
}

/***
 *  Function Name:              ParseRCCommandString
 *  Function Description :      Parses the command string and returns steering, speed, and direction values
 *                              Returns: S<2 char speed>S<2 char steering><F or R>
 *
 *  Argument                Type                        Description
 *  data                    char[]                      Data to be parsed
 *
 */
{int, int, int} ParseRCCommandString (char data[])
{
    //Neutral values
    int steering = 50;
    int speed = 0;
    int direction = FORWARD;

    // Check if incoming data is as expected..
    if (strlen(data) < 8)
    {
        if (data[0] == 'S' && data[3] == 'S' && (data[6] == 'F' || data[6] == 'R'))
        {
            if((isDigit(data[1]) != -1) && (isDigit(data[2]) != -1) && (isDigit(data[4]) != -1) && (isDigit(data[5]) != -1) )
            {
                // Data is valid, now parse it..

                speed = CharToDigit(data[1])*10 + CharToDigit(data[2]);
                steering = CharToDigit(data[4])*10 + CharToDigit(data[5]);

                if(data[6] == 'F')
                {
                    direction = FORWARD;
                }
                else
                {
                    direction = REVERSE;
                }
            }
        }
    }

    return {steering, speed, direction};
}


/***
 *  Function Name:              InitializeRN42asSlave
 *  Function Description :      This function sends some commands to RN42 Module through UART
 *                              to initialize the module as a slave, set the name and password.
 *
 *  Argument                Type                        Description
 *  uart_tx                 client uart_tx_if           UART TX Interface
 */
void InitializeRN42asSlave(client uart_tx_if uart_tx)
{
    //Write some data
    char buffer[]= "$$$";                   // Command mode selection
    WriteData(uart_tx, buffer);
    delay_microseconds(300000); //0.03sec //Wait for the response

    char buffer1[]= "SF,1\r";                // Software reset
    WriteData(uart_tx, buffer1);
    delay_microseconds(300000); //0.03sec //Wait for the response

    char buffer2[]= "SM,0\r";                // set to slave mode
    WriteData(uart_tx, buffer2);
    delay_microseconds(300000); //0.03sec //Wait for the response

    char buffer3[]= "SN,RCCar Bluetooth\r";  // Setting bluetooth name
    WriteData(uart_tx, buffer3);
    delay_microseconds(300000); //0.03sec //Wait for the response

    char buffer4[]= "SP,1234\r";             //Setting Bluetooth pin
    WriteData(uart_tx, buffer4);
    delay_microseconds(300000); //0.03sec //Wait for the response

    char buffer5[]= "R,1\r";                 // Reboot
    WriteData(uart_tx, buffer5);
    delay_microseconds(300000); //0.03sec //Wait for the response
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
    //Debugging related definitions
    timer tmr2;
    unsigned int time2, delay2 = 4000 * MILLISECOND; //4sec
    int set_val = 0;
    int direction_val = REVERSE;
    int speed_val = 0;
    tmr2 :> time2;

    char CommandLine_Buffer[COMMANDLINE_BUFSIZE];
    int char_index = 0;
    char command[COMMANDLINE_BUFSIZE];
    int command_line_ready = 0;
    int speed = 50;
    int steering = 50;
    int direction = FORWARD;

#ifdef RN42_INITIAL_CONFIG
    // Send initialization commands to RN42
    // Do for only first time. Change RN42_INITIAL CONFIG section in rn42_driver.h to do so.
    InitializeRN42asSlave(uart_tx);
#endif

    while (1) {
        //[[ordered]] // Priority in event selection is as ordered below..
        select
        {
            /* DEBUGGING
             * case tmr2 when timerafter(time2) :> void : // Timer event
                steering_interface.ShareSteeringValue(set_val);
                control_interface.ShareDirectionValue(direction_val);
                control_interface.ShareSpeedValue(speed_val);
                time2 += delay2;

                //Toggle to other set value for testing
                if(set_val == 0)
                {
                    set_val = 100;
                    speed_val = 10;
                }
                else if(set_val == 100)
                {
                    set_val = 0;
                    speed_val = 0;
                }

                break;*/

            case uart_rx.data_ready(): //Read when data is available
                uint8_t data = uart_rx.read();

                printf("Data received: %d\n", data);

                // This section is basically dedicated to use the bytes and when the end of line reached,
                // construct the command line.
                if(data != '\r')
                {
                    CommandLine_Buffer[char_index++] = data;
                }
                else // data == \r
                {
                    char_index = 0;

                    //Copy the string to construct the command
                    for(int x = 0; x < strlen(CommandLine_Buffer); x++)
                        command[x] = CommandLine_Buffer[x];

                    //Raise the command line ready flag
                    command_line_ready = 1;
                }

                if ( command_line_ready )
                {
                    {speed, steering, direction} = ParseRCCommandString (command);
                    steering_interface.ShareSteeringValue(steering);
                    control_interface.ShareDirectionValue(direction);
                    control_interface.ShareSpeedValue(speed);
                    command_line_ready = 0;
                }

                break;
        }
    }
}
