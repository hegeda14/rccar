/*
 * light_control.xc
 * Steuerung der Lichteinheit über Channels, erzeugt PWM für Ansteuerung
 * Created on: 15.12.2015
 * Author: Lars
 *
 *
 * 0 Warnblinker
 * 1 Licht vorne + hinten
 * 2 Licht vorne blinken
 * 3 Blinker rechts
 * 4 Blinker links
 * 5 Bremslicht
 * 6 Rückfahrlicht + Bieper
 *
 */
extern out port p_led;

#include <platform.h>
#include <xs1.h>
#include <print.h>
#include <string.h>
#include <stdio.h>

void light_control(chanend c_light) {

    timer t1;
    unsigned int i = 0, time1, mask = 0b1111, light_in = 1;

    int k = 150; // PWM-Signal Lenkung Licht
    int j = 150; // PWM-Signal Motor Licht
    t1 :> time1;
    time1 += 1000;
    while (1) {

        select {

            case t1 when timerafter(time1) :> void:
            i++;
            t1 :> time1;
            time1 += 1000;

            if(i==k)
            {
                mask^=0b0011;
            }

            if(i==j)
            {
                mask^=0b1100;
            }

            if(i==2000)
            {
                i=0;
                mask=0b1111;
            }
            p_led <: mask;
            break;

            case c_light :> light_in:

            if(light_in==0) //Warnblinker
            {
                k = 150;
                j = 150;
            }
            if(light_in==1) //Licht vorne an, Rücklicht halbe Helligkeit
            {
                k = 150;
                j = 120;
            }
            if(light_in==2) //Licht vorne blinken
            {
                k = 150;
                j = 100;
            }
            if(light_in==3) //blinken rechts
            {
                k = 100;
                j = 120;
            }
            if(light_in==4) //blinken links
            {
                k = 200;
                j = 120;
            }
            if(light_in==5) //bremsen
            {
                k = 150;
                j = 180;
            }
            if(light_in==6) // Rückfahrlicht + biepen
            {
                k = 150;
            }
            p_led<:mask;
            break;
        }
    }
}

