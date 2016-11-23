/*
 *  Demanstration der Funktionsfähigkeit des RC-Cars mit dem XMOS sliceKIT
 *
 *  Created on: 06.10.2015
 *  Author: Lars Waldikowski
 */


#include <platform.h>
#include <xs1.h>
#include<print.h>
#include<string.h>
#include <stdio.h>
#include "i2c.h"

#define I2C_NO_REGISTER_ADDRESS 1
#define debounce_time XS1_TIMER_HZ/50
#define BUTTON_PRESS_VALUE 2
#define CORE_NUM  1

on stdcore[CORE_NUM]: out port pwm_led = XS1_PORT_4A;       //  4B für PWM-Signal verwenden und 4A für die Led ausgabe
on stdcore[CORE_NUM]: out port pwm_ledB = XS1_PORT_4B;      // Speed an P2 15 - Control an P2 16
on stdcore[CORE_NUM]: port p_PORT_BUT_1 = XS1_PORT_4C;
on stdcore[CORE_NUM]: struct r_i2c i2cOne = {
      XS1_PORT_1F,
      XS1_PORT_1B,
      1000
 };

void pwm(streaming chanend control ,streaming chanend speed);
void distance_check(chanend button_event, streaming chanend control ,streaming chanend speed,streaming chanend right,streaming chanend left,streaming chanend front,streaming chanend back);
int distance(streaming chanend rechts,streaming chanend links,streaming chanend vorne,streaming chanend hinten);



void button_handler(chanend button_event){  // Abfrage nach Betätigung der beiden Taster

    unsigned button_press_1,button_press_2,time,button_click=0;
     int button = 1;
     timer t;

    p_PORT_BUT_1:> button_press_1;
    set_port_drive_low(p_PORT_BUT_1);

    t:>time;
    printstrln("Buttons Abfrage");
    button_event<:0;

         while(1)
         {
             select
             {
                 case button => p_PORT_BUT_1 when pinsneq(button_press_1):> button_press_1: //checks if any button is pressed
                     button=0;
                     t:>time;
                     break;

                 case !button => t when timerafter(time+debounce_time):>void:   //waits for 20ms and checks if the same button is pressed or not
                     p_PORT_BUT_1:> button_press_2;
                     if(button_press_1 == button_press_2)
                     if(button_press_1 == BUTTON_PRESS_VALUE) //Button 1 is pressed
                     {
                         printstrln("Button 1 gedrückt");
                         if( button_click!=0)
                         {
                         button_click=0;
                         button_event<:0;
                         }
                         else{
                         button_click=1;
                         button_event<:1;
                         }
                     }
                     if(button_press_1 == BUTTON_PRESS_VALUE-1) //Button 2 is pressed
                     {
                        printstrln("Button 2 gedrückt:");
                        if( button_click!=0)
                        {
                        button_click=0;
                        button_event<:0;
                        }
                        else{
                        button_click=2;
                        button_event<:2;
                        }
                        }


                     button=1;
                     break;
             }
             }
         }

//Hauptfunktion, die die Steuerung übernimmt
void distance_check(chanend button_event, streaming chanend control ,streaming chanend speed,streaming chanend right,streaming chanend left,streaming chanend front,streaming chanend back)
{

    unsigned button_wert = 0;
    unsigned abstand_vorne = 0,abstand_hinten=0,abstand_rechts =0,abstand_links=0;

    while(1){

    select{

            case right  :> abstand_rechts:
            break;
            case left   :> abstand_links:
            break;
            case front  :> abstand_vorne:
            break;
            case back   :> abstand_hinten:
            break;
            case button_event :> button_wert:
            break;


            default :

                if(button_wert==0)                      // Fahrzeug bleibt stehen
                    {
                        speed     <: 150000;
                        control   <: 150000;
                    }
                if(button_wert == 1)                    // Abstandregelung vor- und zurückfahren
                    {
                    if(abstand_vorne > 40)
                    {
                    speed <: 145000;
                    }
                    else
                    {
                    speed     <: 150000;    // halten
                    delay_milliseconds(500);

                    if(abstand_vorne < 20 && abstand_hinten > 30)
                    {
                    speed     <: 150000;
                    delay_milliseconds(500);
                    speed     <: 160000;
                    delay_milliseconds(500);
                    speed     <: 150000;
                    delay_milliseconds(1000);
                    }

                    }


            }

                    if(button_wert==2)                  // Programm zum Ausweichen eines Hindernisses
                    {
                        {


                            if(abstand_vorne > 40) // vorwärts
                                {
                                speed <: 145000;
                                 }

                            else

                                    if(abstand_vorne < 40)
                                    {

                                     if(abstand_rechts > 40 && abstand_rechts!=0)  // Testen ob rechts frei zum Ausweichen ist
                                     {
                                          speed         <: 180000;
                                          delay_milliseconds(1000);
                                          control       <: 110000;
                                          speed         <: 150000;
                                          delay_milliseconds(1000);
                                          speed         <: 160000;
                                          delay_milliseconds(1200);  // Zeit rückwärtsfahren
                                          speed         <: 150000;
                                          control       <: 150000;
                                          delay_milliseconds(2000);

                                          control       <: 190000;
                                          speed         <: 150000;
                                          delay_milliseconds(1000);
                                          speed         <: 145000;
                                          delay_milliseconds(2800);  // Zeit vorwärtsfahren
                                          control       <: 150000;
                                          speed         <: 150000;
                                          delay_milliseconds(2000);

                                     }
                                     else if(abstand_links > 40 && abstand_links!=0)  // Testen ob links frei zum Ausweichen ist
                                     {
                                          speed         <: 180000;
                                          delay_milliseconds(1000);
                                          control       <: 190000;
                                          speed         <: 150000;
                                          delay_milliseconds(1000);
                                          speed         <: 160000;
                                          delay_milliseconds(1300); // Zeit rückwärtsfahren
                                          speed         <: 150000;
                                          control       <: 150000;
                                          delay_milliseconds(2000);


                                          control       <: 110000;
                                          speed         <: 150000;
                                          delay_milliseconds(1000);
                                          speed         <: 145000;
                                          delay_milliseconds(3050); // Zeit vorwärtsfahren
                                          control       <: 150000;
                                          speed         <: 150000;
                                          delay_milliseconds(2000);

                                     }
                                     button_wert=0;
                                     speed <: 150000;  // halten wenn keine Bedingung eintrifft oder fehlerhafte Messwerte
                                    }
                                }
                    }
            break;
    }

    }

    }



int main()
{
    streaming chan control, speed, right, left, front, back;
    chan button_event;
      par  // parallel ausgeführte Funktionen
      {
        on stdcore[CORE_NUM]:button_handler(button_event);
        on stdcore[CORE_NUM]:distance_check(button_event, control, speed, right, left, front, back);
        on stdcore[CORE_NUM]:pwm(control ,speed);
        on stdcore[CORE_NUM]:distance(right, left, front, back);
      }
      return 0;
}





void pwm(streaming chanend control ,streaming chanend speed) {  // Erzeugung des PWM-Signals  Werte müssen zwischen 100000 und 200000 liegen

  unsigned  time1 , time2, mask, mask2, flag1=0, flag2=0, delay1=150000 ,delay2=150000, t_low=1800000;

  timer t1;
  timer t2;

  mask = 0b1111;
  mask2= 0b1111;

  // 0 = Led an; 1 = Led aus
    t1 :> time1;
    time1 += t_low;
    t2 :> time2;
    time2 += t_low;

  printstrln("Start PWM-Signal");

  while(1) {

   select{

        case t1 when timerafter(time1) :> void:
           pwm_led <: mask;
           mask^=0b1111;
           t1 :> time1;
           if(flag1==0){
           time1 += delay1; // high Pegel
           flag1=1;
           }
           else{
           time1 += t_low; // 18ms low Pegel  (1,800,000 * 10ns = 18ms)  => 150000 = 1,5 ms
           flag1=0;
           }
           break;

        case t2 when timerafter(time2) :> void:
           pwm_ledB <: mask2;
           mask2^=0b1111;
           t1 :> time2;
           if(flag2==0){
           time2 += delay2; //  high Pegel
           flag2=1;
           }
           else{
           time2 += t_low; // 18ms low Pegel  (1,800,000 * 10ns = 18ms)
           flag2=0;
           }
          break;

        case control :> delay2:
            break;
        case speed :> delay1:
            break;

    }
  }
}


// Ansteuerung der Ultraschallsensoren
int distance(streaming chanend rechts,streaming chanend links,streaming chanend vorne,streaming chanend hinten){

    unsigned char wr_data[1]= {0x51};  //Messung in cm
    unsigned char rd_data[1];
    unsigned char rd_data2[1];
    unsigned temp;


    while(1)
    {

        //Start der Messungen

    i2c_master_write_reg(0x70, 0x00, wr_data, 1, i2cOne); //rechts
    delay_milliseconds(10);
    i2c_master_write_reg(0x71, 0x00, wr_data, 1, i2cOne); //links
    delay_milliseconds(10);
    i2c_master_write_reg(0x73, 0x00, wr_data, 1, i2cOne); //vorne
    delay_milliseconds(10);
    i2c_master_write_reg(0x79, 0x00, wr_data, 1, i2cOne); //hinten
    delay_milliseconds(20); // maximale Dauer einer Messung


    //auslesen der Messwerte und Übergabe an den Channel

    i2c_master_read_reg(0x70,0x02,rd_data2,1,i2cOne);// High Byte Speichern
    i2c_master_read_reg(0x70,0x03,rd_data,1,i2cOne); // Low Byte Speichern

    temp = (rd_data2[0]* 256) + rd_data[0];

    if (temp < 600 && temp > 0) // Abfangen ungültiger Messwerte
        rechts<:temp;
    else
        rechts<:0;

    i2c_master_read_reg(0x71,0x02,rd_data2,1,i2cOne);// High Byte Speichern
    i2c_master_read_reg(0x71,0x03,rd_data,1,i2cOne); // Low Byte Speichern

    temp = (rd_data2[0]* 256) + rd_data[0];

    if (temp < 600 && temp > 0) // Abfangen ungültiger Messwerte
        links<:temp;
    else
        links<:0;

    i2c_master_read_reg(0x73,0x02,rd_data2,1,i2cOne);// High Byte Speichern
    i2c_master_read_reg(0x73,0x03,rd_data,1,i2cOne); // Low Byte Speichern

    temp = (rd_data2[0]* 256) + rd_data[0];

    if (temp < 600 && temp > 0) // Abfangen ungültiger Messwerte
        vorne<:temp;
    else
        vorne<:0;


    i2c_master_read_reg(0x79,0x02,rd_data2,1,i2cOne);// High Byte Speichern
    i2c_master_read_reg(0x79,0x03,rd_data,1,i2cOne); // Low Byte Speichern

    temp = (rd_data2[0]* 256) + rd_data[0];

    if (temp < 600 && temp > 0) // Abfangen ungültiger Messwerte
       hinten<:temp;
    else
        hinten<:0;

    }
    return 0;

}









