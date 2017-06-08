/*
 * Copyright (c) 2017 FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level Module Main Processing Task that processes driving commands over Bluetooth (UART) and Ethernet interface
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

#include "rn42_driver.h"
#include "core_debug.h"

/***
 *  Function Name:              GetLightStateFromCommands
 *  Function Description :      This function uses the speed, steering, and direction information in order to derive the lighting system light state.
 *
 *  Argument                Type                        Description
 *  speed                   int                         Speed value 0-99
 *  steering                int                         Steering value 0-99
 *  direction               int                         Direction value FORWARD or REVERSE
 */
short int GetLightStateFromCommands (int speed, int steering, int direction)
{
    short int lightstate;


    if (steering >= 40 && steering <= 60)
    {
        // Not steering
        if (direction == FORWARD)
        {
            // Going forward
            lightstate = 1;
        }
        else if (direction == REVERSE)
        {
            // Going back
            lightstate = 1;
        }
    }
    else
    {
        // Steering
        if (steering < 40)
        {
            // Going left
            lightstate = 4;
        }
        else if (steering > 60)
        {
            // Going right
            lightstate = 5;
        }
    }
    return lightstate;
}


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
 *  Function Description :      Checks if a character is a digit
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
    return -1;
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
 *  Function Description :      Parses the command string and returns steering, speed, and direction values, respectively.
 *
 *  Argument                Type                        Description
 *  data                    char[]                      Data to be parsed
 *
 */
{int, int, int} ParseRCCommandString (char data[])
{

    // Data is valid, now parse it..
    int speed = 0;
    int steering = 50;
    int direction = FORWARD;

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

    return {speed, steering, direction};
}

/***
 *  Function Name:              InitializeRN42asSlave
 *  Function Description :      This function sends some commands to RN42 Module through UART
 *                              to initialize the module as a slave, and sets the bluetooth device name and password.
 *                              Function is activated by uncommenting the RN42_INITIAL_CONFIG in the header file and
 *                              the configuration should only be done once for a RN42 module.
 *
 *  Argument                Type                        Description
 *  uart_tx                 client uart_tx_if           UART TX Interface
 */
void InitializeRN42asSlave(client uart_tx_if uart_tx)
{
    char buffer[]= "$$$";                   // Enter Command mode to configure the device
    WriteData(uart_tx, buffer);
    delay_microseconds(300000); //0.03sec //Wait for the response

    char buffer1[]= "SF,1\r";                // Software reset
    WriteData(uart_tx, buffer1);
    delay_microseconds(300000); //0.03sec //Wait for the response

    char buffer2[]= "SM,0\r";                // set to slave mode
    WriteData(uart_tx, buffer2);
    delay_microseconds(300000); //0.03sec //Wait for the response

    char buffer6[]= "SA,0\r";                // set to open mode (no authentication)
    WriteData(uart_tx, buffer6);
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

/***
 *  Function Name:              CheckIfCommandFormatIsValid
 *  Function Description :      This function checks the format of the driving command and
 *                              returns 1 if the driving command is as expected
 *
 *  Argument                Type                        Description
 *  command                 char*                       Command string to be checked
 */
int CheckIfCommandFormatIsValid (char* command)
{
    if (command[0] == 'S' && command[3] == 'A' && (command[6] == 'F' || command[6] == 'R'))
    {
        if((isDigit(command[1]) != -1) && (isDigit(command[2]) != -1) && (isDigit(command[4]) != -1) && (isDigit(command[5]) != -1) )
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return 0;
    }
}

/***
 *  Function Name:              Task_MainProcessingAndBluetoothControl
 *  Function Description :      This function communicates with Bluetooth module via UART to obtain
 *                              control interface and steering_inferface values
 *
 *  Argument                        Type                                Description
 *  uart_tx                         client uart_tx_if                   UART TX Interface
 *  uart_rx                         client uart_rx_if                   UART RX Interface
 *  control_interface               client control_if                   Motor speed control value (high level)
 *  steering_interface              client steering_if                  Steering control value (high level)
 *  cmd_from_ethernet_to_override   server ethernet_to_cmdparser_if     Server that reads the driving command if an overriding command is received from the high-level module.
 *  lightstate_interface            client lightstate_if                Client side of the light state interface to send the light state information to the light system task.
 */
[[combinable]]
void Task_MainProcessingAndBluetoothControl(client uart_tx_if uart_tx,
                                            client uart_rx_if uart_rx,
                                            client control_if control_interface,
                                            client steering_if steering_interface,
                                            server ethernet_to_cmdparser_if cmd_from_ethernet_to_override,
                                            client lightstate_if lightstate_interface)
{
    //Debugging related definitions
    timer tmr;
    unsigned int time, delay = RCCAR_STATUS_UPDATE_RATE;
    int set_val = 0;
    int direction_val = REVERSE;
    int speed_val = 0;
    tmr :> time;

    char CommandLine_Buffer[COMMANDLINE_BUFSIZE];
    int char_index = 0;
    char command[COMMANDLINE_BUFSIZE];
    int command_line_ready = 0;
    int speed = 0;
    int steering = 50;
    int direction = FORWARD;
    int previous_direction = FORWARD;

    int ctr = 0;

    char data;

    PrintCoreAndTileInformation("Task_GetRemoteCommandsViaBluetooth");

    // Timing measurement/debugging related definitions
    timer debug_timer;
    uint32_t start_time, end_time;

    char buffer2[]= "SA,0\r";                // set to open mode (no authentication)
    WriteData(uart_tx, buffer2);
    delay_microseconds(300000); //0.03sec //Wait for the response

    //Light system state
    short int lightstate = 2;
    short int previous_lightstate = 2;

#ifdef RN42_INITIAL_CONFIG
    // Send initialization commands to RN42
    // Do for only first time. Change RN42_INITIAL CONFIG section in rn42_driver.h to do so.
    InitializeRN42asSlave(uart_tx);
#endif

    while (1) {
        select
        {
        case uart_rx.data_ready(): //Read when data is available

            //Measure start time
            //debug_timer :> start_time;

            //Receive the data over uart_rx interface.
            data = uart_rx.read();

            // This section is basically dedicated to use the bytes and when the end of line reached,
            // construct the command line.
            if(data != 'E')
            {
                    CommandLine_Buffer[char_index] = data;
                    if(char_index >= COMMANDLINE_BUFSIZE-1) char_index = 0;
                    else char_index++;
            }
            else // data == E
            {
                char_index = 0;
                ctr = 0;

                //Copy the string to construct the command
                for(int x = 0; x < COMMANDLINE_BUFSIZE; x++)
                    command[x] = CommandLine_Buffer[x];

                //Raise the command line ready flag
                command_line_ready = 1;
            }

            //Measure end time
            ////debug_timer :> end_time;
            ////printf("RN42 t: %u", end_time - start_time);

            break;

        //Whenever a driving command comes over ethernet to override local driving commands,
        //it needs to be processed.
        case cmd_from_ethernet_to_override.SendCmd(char* override_command, int cmd_length):
            command_line_ready = 1;
            for(int k=0; k<cmd_length; k++)
            {
                command[k] = override_command[k];
            }
            break;

        //Process the commands received above in a timer event
        case tmr when timerafter(time) :> void : // Timer event
            time += delay;
            if ( command_line_ready )
            {
                // Check if incoming data is as expected..
                if ( CheckIfCommandFormatIsValid(command) == 1 )
                {
                        {speed, steering, direction} = ParseRCCommandString (command);

                        //In order to enable the light system, uncomment below:
                        /*lightstate = GetLightStateFromCommands (speed, steering, direction);
                        if (lightstate != previous_lightstate)
                        {
                                lightstate_interface.ShareLightSystemState  (lightstate);
                        }*/

                        if (previous_direction == FORWARD && direction == REVERSE)
                        {
                                //Commands to cheat into REVERSE mode, so that motor driver is ready for REVERSE movement
                                steering_interface.ShareSteeringValue(50);
                                control_interface.ShareDirectionValue(REVERSE);
                                control_interface.ShareSpeedValue(11);
                                delay_milliseconds(20);
                                steering_interface.ShareSteeringValue(50);
                                control_interface.ShareDirectionValue(REVERSE);
                                control_interface.ShareSpeedValue(53);
                                delay_milliseconds(150);
                                steering_interface.ShareSteeringValue(50);
                                control_interface.ShareDirectionValue(REVERSE);
                                control_interface.ShareSpeedValue(6);
                                delay_milliseconds(50);
                        }

                        steering_interface.ShareSteeringValue(steering);
                        control_interface.ShareDirectionValue(direction);
                        control_interface.ShareSpeedValue(speed);
                        command_line_ready = 0;
                        previous_direction = direction;
                        previous_lightstate = lightstate;

                }
            }

            break;
        }
    }
}
