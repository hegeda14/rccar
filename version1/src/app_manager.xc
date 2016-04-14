/*
 * app_manager.xc
 *
 *  Created on: 03.12.2015
 *  Author: Lars
 *
 *  Hauptfuntion, die die mit allen anderen Tasks kommuniziert um RC-Car zu steuern
 *
 *
 **/

#include "uart_rx.h"
#include "uart_tx.h"
#include <i2c.h>
#include <string.h>
#include <platform.h>
#include <xs1.h>
#include <print.h>
#include <stdio.h>
#include "app_manager.h"


enum {
    GO,
    STOP,
    ULTRA,
    EXIT,
    HELP,
    BUTTON_1,
    BUTTON_2,
    INVALID,
    FRONT,
    BACK,
    LEFT,
    RIGHT,
    PARK1,
    PARK2,
    PARK3,
    PARK4,
    PARK5,
    LICHT0,
    LICHT1,
    LICHT2,
    LICHT3,
    LICHT4,
    LICHT5,
    LICHT6,
    AUSRICHTEN,
    FOLGEN
};


void app_manager(chanend c_uartTX, chanend c_uartRX, chanend c_process,
        chanend c_end, chanend c_control, chanend c_speed, chanend c_right,
        chanend c_left, chanend c_front, chanend c_back, chanend c_light) {
    timer t, t2;
    unsigned char cmd_rcvbuffer[20];
    unsigned abstand_vorne = 0, abstand_hinten = 0, abstand_rechts = 0,
            abstand_links = 0, programm = 0, data = 0, size = 0, time, time2;
    unsigned v_front = 42, steuerung = 1, v_back = 58;
    unsigned j = 0, skip = 1, position = 50, abstand = 30;
    unsigned COMMAND_MODE = 0, RACE_MODE = 0, modus = 0;
    uart_rx_client_state rxState;
    unsigned char eingabe = 'x', vorher = 'n', buffer;
    unsigned fahren = 1, i = 0, zuruck = 0, richtung = 0;
    uart_rx_init(c_uartRX, rxState);
    uart_rx_set_baud_rate(c_uartRX, rxState, BAUD_RATE);
    uart_tx_set_baud_rate(c_uartTX, BAUD_RATE);
    t:>time;

    unsigned char output[100];
    unsigned char fahrtweg[8][150];

    uart_tx_string(c_uartTX,
            strcpy(output, "\r\n***************RC-Car***************\r\n"));

    while (1) {

        select
        {
            case c_right :> abstand_rechts:
            break;

            case c_left :> abstand_links:
            break;

            case c_front :> abstand_vorne:
            break;

            case c_back :> abstand_hinten:
            break;

            case c_end :> data:

            if(data == BUTTON_1) // Begrüßungsmeldung
            {
                uart_tx_string(c_uartTX,strcpy(output,"\r\n***** WELCOME to RC-Car Demo ****\r\n"));
                uart_tx_string(c_uartTX,strcpy(output,"\r\n****ECHO DATA MODE ACTIVATED****\r\n\r\nPress '>cmd' for command mode\r\nPress '>rc'  for rc mode\r\n"));
            }
            if(data == BUTTON_2) // Ausgabe das Button 2 gedrückt wurde
            {
                uart_tx_string(c_uartTX,strcpy(output,"Button 2\r\n"));
            }
            break;

            case uart_rx_get_byte_byref(c_uartRX, rxState, buffer):
            if(buffer == '>') //IUF received data is '>' character then expects cmd to endter into command mode
            {
                j=0;
                uart_rx_get_byte_byref(c_uartRX, rxState, buffer);
                cmd_rcvbuffer[j]=buffer;

                if((cmd_rcvbuffer[j] == 'R' )|| (cmd_rcvbuffer[j] =='r')) //Checks if received data is 'C' or 'c'
                {
                    j++;
                    uart_rx_get_byte_byref(c_uartRX, rxState, buffer);
                    cmd_rcvbuffer[j]=buffer;

                    if((cmd_rcvbuffer[j] == 'C' )|| (cmd_rcvbuffer[j] =='c')) //Checks if received data is 'M' or 'm'
                    {
                        uart_tx_string(c_uartTX,strcpy(output,"\r\n***RACE MODE ACTIVATED***"));
                        uart_tx_string(c_uartTX,strcpy(output,"\r\nSteuerung mit wasd\r\n Beenden mit e\r\n"));
                        c_light <: 1;
                        RACE_MODE=1; //activates command mode as received data is '>cmd'
                        uart_tx_send_byte(c_uartTX, '>'); //displays '>' if rc mode is activated
                    }
                    else
                    {
                        uart_tx_send_byte(c_uartTX, '>');
                        for(int i=0;i<2;i++)
                        uart_tx_send_byte(c_uartTX, cmd_rcvbuffer[i]); // if received data is not 'c' displays back the received data
                    }
                }

                if((cmd_rcvbuffer[j] == 'C' )|| (cmd_rcvbuffer[j] =='c')) //Checks if received data is 'C' or 'c'
                {
                    j=0;
                    uart_rx_get_byte_byref(c_uartRX, rxState, buffer);
                    cmd_rcvbuffer[j]=buffer;

                    if((cmd_rcvbuffer[j] == 'M' )|| (cmd_rcvbuffer[j] =='m')) //Checks if received data is 'M' or 'm'
                    {
                        j++;
                        uart_rx_get_byte_byref(c_uartRX, rxState, buffer);
                        cmd_rcvbuffer[j]=buffer;
                        if((cmd_rcvbuffer[j] == 'D' )|| (cmd_rcvbuffer[j] =='d'))//Checks if received data is 'D' or 'd'
                        {
                            uart_tx_string(c_uartTX,strcpy(output,"\r\n***COMMAND MODE ACTIVATED***"));
                            uart_tx_string(c_uartTX,strcpy(output,"\r\nhelp \t- Display all supported commands"));
                            COMMAND_MODE=1; //activates command mode as received data is '>cmd'
                            uart_tx_send_byte(c_uartTX, '\r');
                            uart_tx_send_byte(c_uartTX, '\n');
                            uart_tx_send_byte(c_uartTX, '>'); //displays '>' if command mode is activated
                            c_light <: 2;
                        }
                        else
                        {
                            uart_tx_send_byte(c_uartTX, '>');
                            for(int i=0;i<3;i++)
                            uart_tx_send_byte(c_uartTX, cmd_rcvbuffer[i]); // if received data is not 'c' displays back the received data
                        }
                    }

                }
            }
            else
            {
                uart_tx_send_byte(c_uartTX,buffer); //Echoes back the input characters if not in command mode
            }

            //::Command
            while(RACE_MODE) //race mode activated
            {
                t2 :> time2;
                time2 +=5000000;

                select {

                    case uart_rx_get_byte_byref(c_uartRX, rxState, buffer): //Abfrage der Tasten für Steuerung des RC-Cars
                    vorher=eingabe;
                    eingabe=buffer;
                    uart_tx_send_byte(c_uartTX, buffer);

                    if(buffer=='w'&&richtung==0)    //Speicherung voreriger Befehl um Lenkung passend einzustellen - Möglichkeit im Stand zu lenken
                    richtung=1;
                    if(buffer=='w'&&richtung==2)
                    richtung=0;
                    if(buffer=='w'&&richtung==1)
                    richtung=1;
                    if(buffer=='s'&&richtung==0)
                    richtung=2;
                    if(buffer=='s'&&richtung==2)
                    richtung=2;
                    if(buffer=='s'&&richtung==1)
                    richtung=0;

                    break;
                    case c_right :> abstand_rechts:
                    break;
                    case c_left :> abstand_links:
                    break;
                    case c_front :> abstand_vorne:
                    break;
                    case c_back :> abstand_hinten:
                    break;

                    case t2 when timerafter(time2) :> void:
                    c_speed <:50;
                    break;
                }

                if(eingabe == 'w')
                {
                    c_light <: 1;
                    if(steuerung==1)
                    c_control <:50;

                    if(abstand_vorne>abstand)
                    {
                        c_speed <:v_front;
                    }
                    else
                    {
                        c_speed<:50;
                    }
                    eingabe ='x';
                }

                if(eingabe == 's')
                {
                    c_light <: 5;
                    if(abstand_hinten>abstand)
                    {
                        c_speed <:v_back;
                    }
                    eingabe ='x';
                }
                if(eingabe == 'a')
                {
                    c_light <: 4;
                    c_control <:90;
                    if(steuerung==1) {
                        if(richtung==1)
                        if(abstand_vorne>abstand)
                        c_speed<:v_front;
                        if(richtung==0)
                        if(richtung==2)
                        c_speed<:v_back;
                    }
                    else
                    {
                        position+=2;
                        if(position <= 10 || position >= 90)
                        {
                            position=90;
                        }
                        c_control <:position;

                    }
                    eingabe ='x';
                }
                if(eingabe == 'd')
                {
                    c_light <: 3;
                    c_control <:10;
                    if(steuerung==1) {
                        if(richtung==1)
                        if(abstand_vorne>abstand)
                        c_speed<:v_front;
                        if(richtung==0)
                        if(richtung==2)
                        c_speed<:v_back;
                    }
                    else {
                        position-=2;
                        if(position <= 10 || position >= 90)
                        {
                            position=10;
                        }
                        c_control <:position;
                    }

                    eingabe ='x';
                }
                if(eingabe == 'q')
                {

                    c_speed <: 50;
                    c_control <: 50;
                    position = 50;
                    eingabe = 'x';
                }

                if(eingabe == 'e')
                {
                    c_light <: 0;
                    c_control <: 50;
                    c_speed <: 50;
                    position = 50;
                    uart_tx_string(c_uartTX,strcpy(output,"\r\nExit RACE MODE\r\n"));
                    RACE_MODE = 0;
                    eingabe = 'x';
                    v_front = 42;
                    steuerung = 0;
                }
                if(eingabe == 't')
                {
                    if(steuerung == 1)
                    steuerung = 0;
                    else
                    steuerung = 1;
                    uart_tx_string(c_uartTX,strcpy(output,"\r\nSteuerung geaendert\r\n"));
                    eingabe ='x';
                }
                if(eingabe == 'z')
                {
                    if(v_front==42) {
                        v_front = 25;
                        abstand = 90;
                    }
                    else {
                        v_front = 42;
                        abstand = 30;
                    }
                    uart_tx_string(c_uartTX,strcpy(output,"\r\nGeschwindigkeit geaendert\r\n"));
                    eingabe = 'x';
                }
            }//race mode

            while(COMMAND_MODE) //Command mode activated
            {
                j=0;
                skip=1;
                while(skip == 1)
                {

                    select
                    {
                        case c_right :> abstand_rechts:
                        break;

                        case c_left :> abstand_links:
                        break;

                        case c_front :> abstand_vorne:
                        break;

                        case c_back :> abstand_hinten:
                        break;

                        case uart_rx_get_byte_byref(c_uartRX, rxState, buffer):
                        cmd_rcvbuffer[j]=buffer;
                        if(cmd_rcvbuffer[j++] == '\r')
                        {
                            skip=0;
                            j=0;
                            while(cmd_rcvbuffer[j] != '\r')
                            {
                                c_process<:cmd_rcvbuffer[j]; //received valid command and send the command to the process_data theread
                                uart_tx_send_byte(c_uartTX, cmd_rcvbuffer[j]);
                                j++;
                            }
                            cmd_rcvbuffer[j]='\0';
                            c_process<:cmd_rcvbuffer[j];
                            for(int inc=0;inc<20;inc++) //Clears the command buffer
                            cmd_rcvbuffer[inc]='0';
                            j=0;
                        }
                        break;
                        case c_end:>data:
                        if(data!=EXIT && data!=INVALID )
                        {
                            uart_tx_string(c_uartTX,strcpy(output,"\r\n---Befehl ausgefuert---\r\n"));
                        }
                        switch(data)
                        {

                            case EXIT: //Ende command mode
                            COMMAND_MODE=0;
                            skip = 0;
                            c_speed <: 50;
                            c_control <: 50;
                            uart_tx_string(c_uartTX,strcpy(output,"\r\nCOMMAND MODE beendet\r\n"));

                            break;

                            case GO: //Starte Motor
                            c_speed <: 45;
                            break;

                            case STOP: //Stopt Motor und laufende Programm
                            c_speed <: 50;
                            c_control<:50;
                            programm=0;
                            break;

                            case PARK1: //Starte vorne rechts parken
                            uart_tx_string(c_uartTX,strcpy(output,"vorne rechts parken\r\n"));
                            programm=1;
                            modus=0;
                            fahren=1;
                            break;

                            case PARK2: //Starte hinten rechts parken
                            uart_tx_string(c_uartTX,strcpy(output,"hinten rechts parken\r\n"));
                            programm=1;
                            modus=2;
                            fahren=1;
                            break;

                            case PARK3: //Starte vorne links parken
                            uart_tx_string(c_uartTX,strcpy(output,"vorne links parken\r\n"));
                            programm=1;
                            modus=4;
                            fahren=1;
                            break;

                            case PARK4: //Starte hinten links parken
                            uart_tx_string(c_uartTX,strcpy(output,"hinten links parken\r\n"));
                            programm=1;
                            modus=6;
                            fahren=1;
                            break;

                            case PARK5: //Parklücke suchen
                            uart_tx_string(c_uartTX,strcpy(output,"Lücke suchen\r\n"));
                            programm=2;
                            fahren=1;
                            break;

                            case AUSRICHTEN: //Starte Ablauf um mittig in der Parklücke zu stehen
                            uart_tx_string(c_uartTX,strcpy(output,"Aussrichten des RC-CARs\r\n"));
                            programm=3;
                            break;

                            case FOLGEN: //Starte Ablauf um mittig in der Parklücke zu stehen
                            uart_tx_string(c_uartTX,strcpy(output,"Folgen \r\n"));
                            programm=4;
                            break;

                            case ULTRA: //Abstand vorderer Sensor

                            unsigned char str1[100];

                            uart_tx_string(c_uartTX,strcpy(output,"vorne\t"));
                            sprintf(str1, "%d", abstand_vorne);
                            uart_tx_string(c_uartTX,strcpy(output,str1));

                            uart_tx_string(c_uartTX,strcpy(output,"\thinten\t"));
                            sprintf(str1, "%d", abstand_hinten);
                            uart_tx_string(c_uartTX,strcpy(output,str1));

                            uart_tx_string(c_uartTX,strcpy(output,"\tlinks\t"));
                            sprintf(str1, "%d", abstand_links);
                            uart_tx_string(c_uartTX,strcpy(output,str1));

                            uart_tx_string(c_uartTX,strcpy(output,"\trechts\t"));
                            sprintf(str1, "%d", abstand_rechts);
                            uart_tx_string(c_uartTX,strcpy(output,str1));
                            uart_tx_string(c_uartTX,strcpy(output,"\r\n"));
                            break;

                            case LICHT0: // Warnblinker
                            c_light <: 0;
                            uart_tx_string(c_uartTX,strcpy(output,"Licht 0  \r\n"));
                            break;

                            case LICHT1: //Frontscheinwerfer
                            c_light <: 1;
                            uart_tx_string(c_uartTX,strcpy(output,"Licht 1  \r\n"));
                            break;

                            case LICHT2: //Frontscheinwerfer blinken
                            c_light <: 2;
                            uart_tx_string(c_uartTX,strcpy(output,"Licht 2  \r\n"));
                            break;

                            case LICHT3: //rechter Blinker
                            c_light <: 3;
                            uart_tx_string(c_uartTX,strcpy(output,"Licht 3  \r\n"));
                            break;

                            case LICHT4: //linker Blinker
                            c_light <: 4;
                            uart_tx_string(c_uartTX,strcpy(output,"Licht 4  \r\n"));
                            break;

                            case LICHT5: //Bremslicht
                            c_light <: 5;
                            uart_tx_string(c_uartTX,strcpy(output,"Licht 5  \r\n"));
                            break;

                            case LICHT6: //Rückfahrlicht + Biepen
                            c_light <: 6;
                            uart_tx_string(c_uartTX,strcpy(output,"Licht 6  \r\n"));
                            break;

                            case FRONT: //Schritt nach vorne fahren
                            c_speed <: 40;
                            delay_milliseconds(1000);
                            c_speed <: 50;
                            break;

                            case BACK: //Schritt zurück

                            c_speed <: 50;
                            delay_milliseconds(800);
                            c_speed <: 60;
                            delay_milliseconds(800);
                            c_speed <: 50;
                            delay_milliseconds(1000);
                            break;

                            case LEFT: //Lenkeinschlag links
                            c_control<:90;
                            break;

                            case RIGHT: //Lenkeinschlag rechts
                            c_control<:10;
                            break;

                            case BUTTON_1:
                            break;

                            case BUTTON_2:
                            break;

                            case HELP: //Displays help messages on Uart

                            uart_tx_string(c_uartTX,strcpy(output,"\r\n\r\n--------------------HELP----------------------\r\n"));
                            uart_tx_string(c_uartTX,strcpy(output,"front\tright\tleft\tback\t-Fahren/LEnken\r\n"));
                            uart_tx_string(c_uartTX,strcpy(output,"ultra\t-\tAusgabe der Ultraschallmesswerte\r\n"));
                            uart_tx_string(c_uartTX,strcpy(output,"park1 bis park4\t-Einparken\r\n"));
                            uart_tx_string(c_uartTX,strcpy(output,"licht0 bis licht6\t-Lichtsteuerung \r\n"));
                            uart_tx_string(c_uartTX,strcpy(output,"exit\t-\tBeende cmd-Modus\r\n"));

                            break;

                            case INVALID: // ungültiger Befehl
                            uart_tx_string(c_uartTX,strcpy(output,"ungueltiger Befehl\r\n"));
                            break;

                            if(data != EXIT) //Ende Command Mode
                            {
                                uart_tx_send_byte(c_uartTX, '\r');
                                uart_tx_send_byte(c_uartTX, '\n');
                                uart_tx_send_byte(c_uartTX, '>');
                            }
                            break;

                        }//select switch data


                        break;

                        default:

                        if(programm == 0) // Fahrzeug bleibt stehen
                        {
                            c_speed <: 50;
                            c_control <: 50;
                        }

                        if(programm == 1) // Programm Einparken
                        {

                            i=1;
                            strcpy(fahrtweg[0] , "dddwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwaaawwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwnq"); //park1
                            strcpy(fahrtweg[1] , "aaawsnnssssssssssssssssssssssssssssssssnnndddwsnnssssssssssssssssssssssssssssssssssnnnnq");
                            strcpy(fahrtweg[2] , "dddwsnnssssssssssssssssssssssssssssssssssssssssssnnnnaaawsnnnsssssssssssssssssssssssssssssssssssssssssssnnnnnnnnnnnnq"); //park2
                            strcpy(fahrtweg[3] , "aaaawwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwnndddwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwnnnnnnnnnnnnnnnnnq");
                            strcpy(fahrtweg[4] , "aaawwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwnnnnnnndddwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwnq"); //park3
                            strcpy(fahrtweg[5] , "dddwsnnssssssssssssssssssssssssssssssssssssnnnnnnnnnnaaawsnnnssssssssssssssssssssssssssssssssssssnnnnq");
                            strcpy(fahrtweg[6] , "aaawsnnssssssssssssssssssssssssssssssssssssssssssssssdddwsnnnsssssssssssssssssssssssssssssssssssssssssssssnnnq"); //park4
                            strcpy(fahrtweg[7] , "dddwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwnaaaawwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwnq");

                            t2 :> time2;
                            time2 +=5000000;

                            size = strlen (fahrtweg[modus]);

                            while(fahren)
                            {
                                t2 :> time2;
                                time2 +=5000000;

                                select {

                                    case c_right :> abstand_rechts:
                                    break;
                                    case c_left :> abstand_links:
                                    break;
                                    case c_front :> abstand_vorne:
                                    break;
                                    case c_back :> abstand_hinten:
                                    break;

                                    case t2 when timerafter(time2) :> void: // Zeit bis zum nächsten Befehl
                                    c_speed <: 50;

                                    if(zuruck == 0) {
                                        if(fahrtweg[modus][i]!='\0') {
                                            eingabe=fahrtweg[modus][i];
                                            uart_tx_send_byte(c_uartTX, eingabe);}
                                        else {
                                            fahren = 0;
                                        }
                                    }
                                    if(zuruck == 1) {
                                        if(fahrtweg[modus+1][i]!='\0') {
                                            eingabe=fahrtweg[modus+1][i];
                                            uart_tx_send_byte(c_uartTX, eingabe);}
                                        else {
                                            fahren=0;
                                        }
                                    }

                                    if(i < 1 || i > size) {
                                        fahren = 0;
                                        zuruck = 0;
                                        uart_tx_send_byte(c_uartTX, 'I');
                                    }
                                    i++;
                                    break;

                                } //select

                                if(zuruck==0) { // vorwärtsfahrt, wenn kein Hindernis vorliegt
                                    if(eingabe == 'w')
                                    {
                                        if(abstand_vorne>30)
                                        {
                                            c_speed <:v_front;

                                        }
                                        else
                                        {
                                            c_speed<:50;
                                            zuruck=1;
                                            uart_tx_send_byte(c_uartTX, 'X');
                                            i=size-i;
                                            if(i>5) // Anpassung für Rückwärtsfahrt
                                            {
                                                fahrtweg[modus+1][i-1]='n';
                                                fahrtweg[modus+1][i-2]='n';
                                                fahrtweg[modus+1][i-3]='n';
                                                fahrtweg[modus+1][i-4]='s';
                                                fahrtweg[modus+1][i-5]='s';
                                                i-=5;
                                            }
                                            else
                                            {
                                                fahrtweg[modus+1][5]='n';
                                                fahrtweg[modus+1][4]='n';
                                                fahrtweg[modus+1][3]='s';
                                                fahrtweg[modus+1][2]='s';
                                                fahrtweg[modus+1][1]='s';
                                                i=1;
                                            }
                                        }
                                        eingabe ='x';
                                    }

                                    if(eingabe == 's')
                                    {
                                        if(abstand_hinten>30)
                                        {
                                            c_speed <:v_back;
                                        }
                                        else
                                        {
                                            c_speed<:50;
                                            zuruck=1;
                                            i=size-i;
                                            uart_tx_send_byte(c_uartTX, 'X');
                                        }
                                        eingabe ='x';
                                    }
                                    if(eingabe == 'a')
                                    {
                                        c_control <:90;
                                        c_light <: 4;
                                        eingabe ='x';

                                    }
                                    if(eingabe == 'd')
                                    {
                                        c_control <:10;
                                        c_light <: 3;
                                        eingabe ='x';
                                    }
                                    if(eingabe == 'n')
                                    {
                                        c_speed <:50;
                                        c_light <: 1;
                                    }
                                    if(eingabe == 'q')
                                    {
                                        uart_tx_string(c_uartTX,strcpy(output,"\r\nAuto hat Parkposition erreicht\r\n"));
                                        c_speed <: 50;
                                        c_control <: 50;
                                        eingabe = 'x';
                                        fahren = 0;
                                        c_light <: 2;
                                        uart_tx_send_byte(c_uartTX, '\r');
                                        uart_tx_send_byte(c_uartTX, '\n');
                                        programm=3;

                                    }
                                } //zuruck


                                if(zuruck==1) {

                                    if(eingabe == 'w')
                                    {
                                        if(abstand_vorne > 30)
                                        {
                                            c_speed <:v_front;
                                        }
                                        else
                                        {
                                            c_speed <: 50;
                                            zuruck = 0;
                                            fahren = 0;
                                            uart_tx_send_byte(c_uartTX, 'I');
                                        }
                                        eingabe ='x';
                                    }

                                    if(eingabe == 's')
                                    {
                                        if(abstand_hinten > 30 )
                                        {
                                            c_speed <:v_back;
                                        }
                                        else
                                        {
                                            c_speed <: 50;
                                            zuruck = 0;
                                            fahren = 0;
                                            uart_tx_send_byte(c_uartTX, 'I');
                                        }
                                        eingabe ='x';
                                    }
                                    if(eingabe == 'a')
                                    {
                                        c_control <: 90;
                                        c_light <: 4;
                                        eingabe = 'x';
                                    }
                                    if(eingabe == 'd')
                                    {
                                        c_control <:10;
                                        c_light <: 3;
                                        eingabe ='x';
                                    }
                                    if(eingabe == 'n')
                                    {
                                        c_speed <:50;

                                    }
                                    if(eingabe == 'q')
                                    {

                                        c_speed     <:  50;
                                        c_control   <:  50;
                                        eingabe     =   'x';
                                        fahren      =   0;
                                        zuruck      =   0;
                                        uart_tx_send_byte(c_uartTX, '\r');
                                        uart_tx_send_byte(c_uartTX, '\n');
                                        c_light <: 0;
                                    }
                                } //else zuruck = 1


                            }//while
                            c_speed <:50;
                            c_control <:50; //Lenkung gerade ziehen


                        }

                        if(programm==2) { //Parklücke  auf der rechten Seite des RC-Cars erkennen

                            t2 :> time2;
                            time2 +=5000000;
                            unsigned parken=0;

                            while(programm==2)
                            {

                                select {

                                    case c_right :> abstand_rechts:
                                    break;
                                    case c_left :> abstand_links:
                                    break;
                                    case c_front :> abstand_vorne:
                                    break;
                                    case c_back :> abstand_hinten:
                                    break;

                                    case t2 when timerafter(time2) :> void:
                                    c_speed <:50;

                                    t2 :> time2;
                                    time2 +=5000000;
                                    break;

                                    default:

                                    if(abstand_rechts < 30 ) {
                                        c_speed <:43;
                                     }

                                    else {
                                        modus = 0;
                                        programm = 1;
                                        uart_tx_string(c_uartTX,strcpy(output,"rechts parken\r\n"));
                                    }
                                break;
                            }
                        }

                    } // Programm 2 Ende


                    if(programm==3) { // Auto ausrichten
                        c_light <: 0;
                        t2 :> time2;
                        time2 +=5000000;
                        i=0;
                        uart_tx_string(c_uartTX,strcpy(output,"\r\nmittig parken\r\n"));
                        while(programm==3) {

                            select {

                                case c_right :> abstand_rechts:
                                break;
                                case c_left :> abstand_links:
                                break;
                                case c_front :> abstand_vorne:
                                break;
                                case c_back :> abstand_hinten:
                                break;
                                case t2 when timerafter(time2) :> void:
                                c_speed <:50;
                                i++;
                                t2 :> time2;
                                time2 +=5000000;
                                break;
                            }

                            if(abstand_vorne > abstand_hinten )
                            {
                                if(abstand_vorne>30)
                                {
                                    c_speed <: 43;
                                    uart_tx_send_byte(c_uartTX, '+');
                                    i=0;
                                }
                            }

                            else
                            {
                                c_speed <: 50;

                                if((abstand_hinten > abstand_vorne + 5 ) && programm == 3)
                                {
                                    if(abstand_hinten>30) {
                                        uart_tx_send_byte(c_uartTX, '-');
                                        if(i<5)
                                        c_speed <: 45;
                                        if(i>5&&i<10)
                                        c_speed <: 60;
                                        if(i>10&&i<30)
                                        c_speed <: 50;
                                        if(i>30)
                                        c_speed <: v_back;
                                        if(i>40)
                                        i=0;
                                    }
                                }
                                else {

                                    uart_tx_string(c_uartTX,strcpy(output,"\r\n---Parkvorgang abgeschlossen---\r\n"));
                                    programm=0;
                                    i=0;
                                    c_speed <: 50;
                                    c_control <: 50;

                                }
                            }

                        }//while


                    } //Programm 3 Ende


                    if(programm==4) //folgen
                    {

                        c_light <: 1;
                        t2 :> time2;
                        time2 +=5000000;
                        i=0;
                        uart_tx_string(c_uartTX,strcpy(output,"\r\nfolgen\r\n"));
                        while(programm==4) {

                            select {

                                case c_right :> abstand_rechts:
                                break;
                                case c_left :> abstand_links:
                                break;
                                case c_front :> abstand_vorne:
                                break;
                                case c_back :> abstand_hinten:
                                break;
                                case t2 when timerafter(time2) :> void:
                                c_speed <:50;
                                i++;
                                t2 :> time2;
                                time2 +=5000000;
                                break;
                            }

                            if(abstand_vorne>30)
                            {
                                c_speed <: 42;
                                i=0;
                            }
                            if(abstand_vorne<25)
                            {
                                c_speed <: 50;
                                if(abstand_hinten>30) {
                                    c_light <: 5;
                                    if(i<5)
                                    c_speed <: 45;
                                    if(i>5&&i<10)
                                    c_speed <: 60;
                                    if(i>10&&i<30)
                                    c_speed <: 50;
                                    if(i>30)
                                    c_speed <: 58;
                                    if(i>40)
                                    i=0;
                                }
                                else {
                                    uart_tx_string(c_uartTX,strcpy(output,"\r\n---Ende---\r\n"));
                                    programm=0;
                                    i=0;
                                    c_speed <: 45;
                                    c_control <: 50;
                                    c_light <: 0;
                                }
                            }
                        }//while
                    } //programm 4
                    break;
                }//select
            }
            //skip
            j = 0;
        }
        //command modee
        break; //cmd und rc mode
    }
    //main select
}//superloop
}//thread




/** =========================================================================
 *
 * Transmits byte by byte to the UART TX thread for an input string
 *
 **/
void uart_tx_string(chanend c_uartTX, unsigned char message[100]) //transmit string on Uart TX terminal
{
int i = 0;
while (message[i] != '\0') {
    uart_tx_send_byte(c_uartTX, message[i]); //send data to uart byte by byte
    i++;
}
}
