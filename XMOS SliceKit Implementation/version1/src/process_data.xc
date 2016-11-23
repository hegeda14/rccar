/** =========================================================================
 * process data
 *
 * Überprüft ob der eingegebene Befehl vorhanden ist oder nicht, Abfrage der der Buttons
 *
 *
 **/
#include <string.h>
#include <platform.h>
#include <xs1.h>
#include <print.h>
#include <stdio.h>

#define debounce_time XS1_TIMER_HZ/50
#define BUTTON_PRESS_VALUE 2

extern port p_button1;

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


void process_data(chanend c_process, chanend c_end) {
    int skip = 1, i = 0;
    unsigned button_value1, button_value2;
    unsigned char cmd_rcvbuffer[20];
    int button = 1, button1_pressed = 0, button2_pressed = 0;
    timer t;
    unsigned time;
    set_port_drive_low(p_button1);
    p_button1:>button_value1;
    while (1) {
        //::select in process data
        select
        {
            case button => p_button1 when pinsneq(button_value1):>button_value1:
            t:>time;
            button=0;
            break;

            case !button => t when timerafter(time+debounce_time):>void: //Read button values for every 20 ms
            p_button1:> button_value2;
            //checks if button 1 is pressed or button 2 is pressed
            if(button_value1 == button_value2)
            if(button_value1 == BUTTON_PRESS_VALUE)
            {
                button1_pressed=1;

                c_end<:BUTTON_1; // Button 1 gedrückt
            }
            if(button_value1 == BUTTON_PRESS_VALUE-1)
            {
                button2_pressed=1;

                c_end<:BUTTON_2; //Button 2 gedrückt

            }
            button=1;
            break;

            case c_process :> cmd_rcvbuffer[i]:
            i+=1;
            skip=1;
            while(skip == 1)
            {
                c_process:>cmd_rcvbuffer[i];
                if(cmd_rcvbuffer[i++] == '\0') //Reveived the command from  app_manager thread
                skip=0;
            }
            //Checks if received command is valid command or not and sends state machine value to app manager thread
            if(!strcmp(cmd_rcvbuffer,"exit"))
            {
                c_end<:EXIT;
            }

            else if(!strcmp(cmd_rcvbuffer,"help"))
            {
                c_end<:HELP;
            }

            else if(!strcmp(cmd_rcvbuffer,"go"))
            {
                c_end<:GO;
            }
            else if(!strcmp(cmd_rcvbuffer,"stop"))
            {
                c_end<:STOP;
            }
            else if(!strcmp(cmd_rcvbuffer,"park1"))
            {
                c_end<:PARK1;
            }
            else if(!strcmp(cmd_rcvbuffer,"park2"))
            {
                c_end<:PARK2;
            }
            else if(!strcmp(cmd_rcvbuffer,"park3"))
            {
                c_end<:PARK3;
            }
            else if(!strcmp(cmd_rcvbuffer,"park4"))
            {
                c_end<:PARK4;
            }
            else if(!strcmp(cmd_rcvbuffer,"park5"))
            {
                c_end<:PARK5;
            }
            else if(!strcmp(cmd_rcvbuffer,"licht0"))
            {
                c_end<:LICHT0;
            }
            else if(!strcmp(cmd_rcvbuffer,"licht1"))
            {
                c_end<:LICHT1;
            }
            else if(!strcmp(cmd_rcvbuffer,"licht2"))
            {
                c_end<:LICHT2;
            }
            else if(!strcmp(cmd_rcvbuffer,"licht3"))
            {
                c_end<:LICHT3;
            }
            else if(!strcmp(cmd_rcvbuffer,"licht4"))
            {
                c_end<:LICHT4;
            }
            else if(!strcmp(cmd_rcvbuffer,"licht5"))
            {
                c_end<:LICHT5;
            }
            else if(!strcmp(cmd_rcvbuffer,"licht6"))
            {
                c_end<:LICHT6;
            }
            else if(!strcmp(cmd_rcvbuffer,"ultra"))
            {
                c_end<:ULTRA;
            }
            else if(!strcmp(cmd_rcvbuffer,"ausrichten"))
            {
                c_end<:AUSRICHTEN;
            }
            else if(!strcmp(cmd_rcvbuffer,"folgen"))
            {
                c_end<:FOLGEN;
            }
            else
            {
                c_end<:INVALID;
            }
            i=0;
            for(int inc=0;inc<20;inc++)
            cmd_rcvbuffer[inc]='0'; //Clear command reveive buffer
            break;
        }
    }    //::Select
}
