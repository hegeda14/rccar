/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/

#include "sonar_sensor.h"


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


int InitializeMessaging (client i2c_master_if i2c_interface)
{
    int error_flag = 0;
    i2c_regop_res_t result;

    // Start messaging
    result = i2c_interface.write_reg(getDistanceSensorAddr(LEFT_DISTANCE_SENSOR_ID), 0x00, WRDATA_CENTIMETERS); //Left Sensor //Args: addr, reg, data
    if (result != I2C_REGOP_SUCCESS) {
        //printf("I2C write reg failed\n");
        error_flag = -1;
    }
    //delay_milliseconds(10); //Work out the delays

    result = i2c_interface.write_reg(getDistanceSensorAddr(RIGHT_DISTANCE_SENSOR_ID), 0x00, WRDATA_CENTIMETERS); //Right Sensor //Args: addr, reg, data
    if (result != I2C_REGOP_SUCCESS) {
        //printf("I2C write reg failed\n");
        error_flag = -1;
    }
    //delay_milliseconds(10);

    result = i2c_interface.write_reg(getDistanceSensorAddr(FRONT_DISTANCE_SENSOR_ID), 0x00, WRDATA_CENTIMETERS); //Front Sensor //Args: addr, reg, data
    if (result != I2C_REGOP_SUCCESS) {
        //printf("I2C write reg failed\n");
        error_flag = -1;
    }
    //delay_milliseconds(10);

    result = i2c_interface.write_reg(getDistanceSensorAddr(REAR_DISTANCE_SENSOR_ID), 0x00, WRDATA_CENTIMETERS); //Rear Sensor //Args: addr, reg, data
    if (result != I2C_REGOP_SUCCESS) {
        //printf("I2C write reg failed\n");
        error_flag = -1;
    }
    //delay_milliseconds(20);

    return error_flag;
}


/***
 *  Function Name:              Task_ReadSonarSensors
 *  Function Description :      Reads 4 SRF02 Ultrasonic sensor values and published them to interface
 *                              sensors_interface
 *
 *  Argument                Type                                        Description
 *  i2c_interface           client i2c_master_if i2c_interface          Master Mode I2C Comm Interface
 *  sensors_interface       client distancesensor_if                    Used to share distance sensor values
 */

void Task_ReadSonarSensors(client i2c_master_if i2c_interface, client distancesensor_if sensors_interface)
{
    // One function could work with 4 instances, therefore 4 sensors

    // Declare some variables to use later
    i2c_regop_res_t result;
    uint8_t high_byte;
    uint8_t low_byte;
    unsigned acc; //accumulator for distance measurement
    uint8_t left, right, front, rear;

    timer tmr3;
    uint32_t time3, delay3 = SENSOR_READ_PERIOD; //.8sec

    // Timing measurement/debugging related definitions
    timer debug_timer;
    uint32_t start_time, end_time;

    tmr3 :> time3;

    while (1) {
        select
        {
            case tmr3 when timerafter(time3) :> void :
                //Measure start time
                ////debug_timer :> start_time;

                //Initialize messaging
                InitializeMessaging(i2c_interface);

                // For Left Sensor
                // Read from high and low byte respectively
                high_byte = i2c_interface.read_reg(getDistanceSensorAddr(LEFT_DISTANCE_SENSOR_ID), 0x02, result);
                low_byte = i2c_interface.read_reg(getDistanceSensorAddr(LEFT_DISTANCE_SENSOR_ID),  0x03, result);
                // Construct the distance information in centimeters
                acc = (high_byte * 256) + low_byte;
                if ((acc < 600)  && (acc > 0)) // Distance should be in between 600cm and 0cm
                {
                    left = acc;
                }
                else
                {
                    left = 0;
                }
                //printf("y\n");

                // For Right Sensor
                // Read from high and low byte respectively
                high_byte = i2c_interface.read_reg(getDistanceSensorAddr(RIGHT_DISTANCE_SENSOR_ID), 0x02, result);
                low_byte = i2c_interface.read_reg(getDistanceSensorAddr(RIGHT_DISTANCE_SENSOR_ID),  0x03, result);
                // Construct the distance information in centimeters
                acc = (high_byte * 256) + low_byte;
                if ((acc < 600)  && (acc > 0)) // Distance should be in between 600cm and 0cm
                {
                    right = acc;
                }
                else
                {
                    right = 0;
                }
                //printf("z\n");

                // For Front Sensor
                // Read from high and low byte respectively
                high_byte = i2c_interface.read_reg(getDistanceSensorAddr(FRONT_DISTANCE_SENSOR_ID), 0x02, result);
                low_byte = i2c_interface.read_reg(getDistanceSensorAddr(FRONT_DISTANCE_SENSOR_ID),  0x03, result);
                // Construct the distance information in centimeters
                acc = (high_byte * 256) + low_byte;
                if ((acc < 600)  && (acc > 0)) // Distance should be in between 600cm and 0cm
                {
                    front = acc;
                }
                else
                {
                    front = 0;
                }


                // For Rear Sensor
                // Read from high and low byte respectively
                high_byte = i2c_interface.read_reg(getDistanceSensorAddr(REAR_DISTANCE_SENSOR_ID), 0x02, result);
                low_byte = i2c_interface.read_reg(getDistanceSensorAddr(REAR_DISTANCE_SENSOR_ID),  0x03, result);
                // Construct the distance information in centimeters
                acc = (high_byte * 256) + low_byte;
                if ((acc < 600)  && (acc > 0)) // Distance should be in between 600cm and 0cm
                {
                    rear = acc;
                }
                else
                {
                    rear = 0;
                }

                // Send sensor values all together
                sensors_interface.ShareDistanceSensorValues (left, right, front, rear);

                // Delay
                time3 += delay3;

                //Measure end time
                ////debug_timer :> end_time;
                ////printf("SONAR t: %u", end_time - start_time);
                break;
        }
    }
}
