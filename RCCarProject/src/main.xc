/***
 * All rights belong to PIMES, FH Dortmund
 * Intented for the RC-Car project by PIMES
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @version 1.0
 * @contact mozcelikors@gmail.com
 **/

// Includes
#include <xs1.h>
#include <platform.h>
#include <gpio.h>
#include "debug_print.h"
#include <print.h>
#include <string.h>
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <uart.h>
#include <i2c.h>

// I2C Related Defines
#define I2C_CLIENT_DEVICE_COUNT ((size_t) 4)   //In our case, ultrasonic sensor count
#define I2C_SPEED_KBITPERSEC    ((unsigned) 10)  // ?? Check later
#define Task_MaintainI2CConnection i2c_master //Renaming i2c_master for more visual appeal

// I2C Related Ports
on tile[0] : port PortSCL = XS1_PORT_1E;
on tile[0] : port PortSDA = XS1_PORT_1F;

// Distance sensor related Defines
#define WRDATA_CENTIMETERS ((uint8_t)0x51)

#define LEFT_DISTANCE_SENSOR_ID     0
#define RIGHT_DISTANCE_SENSOR_ID    1
#define FRONT_DISTANCE_SENSOR_ID    2
#define REAR_DISTANCE_SENSOR_ID     3

#define LEFT_DISTANCE_SENSOR_DEVICEADDR     ((uint8_t) 0x71)
#define RIGHT_DISTANCE_SENSOR_DEVICEADDR    ((uint8_t) 0x70)
#define FRONT_DISTANCE_SENSOR_DEVICEADDR    ((uint8_t) 0x73)
#define REAR_DISTANCE_SENSOR_DEVICEADDR     ((uint8_t) 0x74)

// Distance Sensor Value Sharing Interface
typedef interface distancesensor_if
{
    void ShareSensorValue (uint8_t sensor_value);
} distancesensor_if;

uint8_t getDistanceSensorAddr (int sensor_id)
{
    switch (sensor_id)
    {
        case LEFT_DISTANCE_SENSOR_ID:   return LEFT_DISTANCE_SENSOR_DEVICEADDR;    break;
        case RIGHT_DISTANCE_SENSOR_ID:  return RIGHT_DISTANCE_SENSOR_DEVICEADDR;   break;
        case FRONT_DISTANCE_SENSOR_ID:  return FRONT_DISTANCE_SENSOR_DEVICEADDR;   break;
        case REAR_DISTANCE_SENSOR_ID:   return REAR_DISTANCE_SENSOR_DEVICEADDR;    break;
        default: return FRONT_DISTANCE_SENSOR_DEVICEADDR;   break;
    }
    return FRONT_DISTANCE_SENSOR_DEVICEADDR;
}

void Task_ReadSonarSensor(client interface i2c_master_if i2c_interface, client interface distancesensor_if sensor_interface, int sensor_id)
{
    // One function could work with 4 instances, therefore 4 sensors

    // Declare some variables to use later
    i2c_regop_res_t result;
    uint8_t high_byte;
    uint8_t low_byte;
    unsigned acc; //accumulator for distance measurement

    while(1)
    {
        // Start messaging
        result = i2c_interface.write_reg(getDistanceSensorAddr(sensor_id), 0x00, WRDATA_CENTIMETERS);//Args: addr, reg, data
        if (result != I2C_REGOP_SUCCESS) {
            debug_printf("I2C write reg failed\n");
        }
        delay_milliseconds(20);

        // Read from high and low byte respectively
        high_byte = i2c_interface.read_reg(getDistanceSensorAddr(sensor_id), 0x02, result);
        low_byte = i2c_interface.read_reg(getDistanceSensorAddr(sensor_id),  0x03, result);

        // Construct the distance information
        acc = (high_byte * 256) + low_byte;
        if ((acc < 600)  && (acc > 0))
        {
            sensor_interface.ShareSensorValue(acc);
        }
        else
        {
            sensor_interface.ShareSensorValue(0);
        }
    }
}

void Task_ProduceMotorControlOutputs (server interface distancesensor_if leftsensor,
                                      server interface distancesensor_if rightsensor,
                                      server interface distancesensor_if frontsensor,
                                      server interface distancesensor_if rearsensor)
{

}

void Task_DriveMotorsUsingPWM ()
{

}

int main() {
  i2c_master_if i2c_client_device_instances[I2C_CLIENT_DEVICE_COUNT];
  distancesensor_if rightsensor_interface;
  distancesensor_if leftsensor_interface;
  distancesensor_if frontsensor_interface;
  distancesensor_if rearsensor_interface;

  par {
     on tile[0] : Task_MaintainI2CConnection(i2c_client_device_instances, I2C_CLIENT_DEVICE_COUNT, PortSCL, PortSDA, I2C_SPEED_KBITPERSEC);
     on tile[0] : Task_ReadSonarSensor(i2c_client_device_instances[0], leftsensor_interface, LEFT_DISTANCE_SENSOR_ID); //left sensor
     on tile[0] : Task_ReadSonarSensor(i2c_client_device_instances[1], rightsensor_interface,RIGHT_DISTANCE_SENSOR_ID); //right sensor
     on tile[0] : Task_ReadSonarSensor(i2c_client_device_instances[2], frontsensor_interface,FRONT_DISTANCE_SENSOR_ID); //front sensor
     on tile[0] : Task_ReadSonarSensor(i2c_client_device_instances[3], rearsensor_interface, REAR_DISTANCE_SENSOR_ID); //rear sensor
     on tile[0] : Task_ProduceMotorControlOutputs(leftsensor_interface,
                                                  rightsensor_interface,
                                                  frontsensor_interface,
                                                  rearsensor_interface);
  } 

   return 0;
}

