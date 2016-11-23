/*
 * distance.xc
 * Ansteuerung der Ultraschallsensoren
 * Übergabe der jeweiligen Messwerte über eigenen Channel
 * Created on: 02.12.2015
 *  Author: Lars
 */

#include "i2c.h"


extern struct r_i2c i2cOne;


int distance(chanend c_rechts, chanend c_links, chanend c_vorne, chanend c_hinten){

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
        c_rechts<:temp;
    else
        c_rechts<:0;

    i2c_master_read_reg(0x71,0x02,rd_data2,1,i2cOne);// High Byte Speichern
    i2c_master_read_reg(0x71,0x03,rd_data,1,i2cOne); // Low Byte Speichern

    temp = (rd_data2[0]* 256) + rd_data[0];

    if (temp < 600 && temp > 0) // Abfangen ungültiger Messwerte
        c_links<:temp;
    else
        c_links<:0;

    i2c_master_read_reg(0x73,0x02,rd_data2,1,i2cOne);// High Byte Speichern
    i2c_master_read_reg(0x73,0x03,rd_data,1,i2cOne); // Low Byte Speichern

    temp = (rd_data2[0]* 256) + rd_data[0];

    if (temp < 600 && temp > 0) // Abfangen ungültiger Messwerte
        c_vorne<:temp;
    else
        c_vorne<:0;


    i2c_master_read_reg(0x79,0x02,rd_data2,1,i2cOne);// High Byte Speichern
    i2c_master_read_reg(0x79,0x03,rd_data,1,i2cOne); // Low Byte Speichern

    temp = (rd_data2[0]* 256) + rd_data[0];

    if (temp < 600 && temp > 0) // Abfangen ungültiger Messwerte
        c_hinten<:temp;
    else
        c_hinten<:0;

    }

    return 0;
}
