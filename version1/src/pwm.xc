/*
 *      pwm.xc
 *
 *      Created on: 02.12.2015
 *      Author: Lars
 *      Erzeugt PWM-Signal für Motor und Lenkung
 *      Eingabewerte von 0 - 100; werden in PWM mit 1 ms bis 2 ms umgewandelt
 */
#include <platform.h>
#include <xs1.h>
#include <print.h>
#include <string.h>
#include <stdio.h>

extern out port p_pwm;

void pwm(chanend c_control, chanend c_speed) {

    unsigned time1, mask;
    timer t1;
    unsigned int i = 0, temp1 = 50, temp2 = 50;

    mask = 0b1111;

    int k = 150; // Lenkung
    int j = 150; // Motor

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
            p_pwm <: mask;
            break;

            case c_control :> temp1:        // Übernahme neuer Lenkwert
            if(0<=temp1&&temp1<=100)
            k=temp1+100;
            break;

            case c_speed :> temp2:          // Übernahme neue Geschwindigkeit
            if(0<=temp2&&temp2<=100)
            j=temp2+100;
            break;
        }
    }
}

