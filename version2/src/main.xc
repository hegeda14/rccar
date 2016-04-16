/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @version 2.0.1
 * @contact mozcelikors@gmail.com
 ************************************************************************************
 * NOTES
 * In order to debug the project using printf, which is really handy, one has to do the following steps :
 * 1) Makefile should have -fxscope flag for XCG FLAGS section
 * 2) Run > Run Configurations > Filtering Preferences : Untick xCORE Application
 * 3) Then, select xCORE Application, Browse to find the project and its details, and select hardware.
 * 4) Hardware debug means that XTAG and printf will be used, One can also debug using other options, such as xSCOPE.
 * For more information, refer to xTIMEcomposer User Guide Chapter 24 and 15.
 * Simulator debug is handy as well, especially for PWM. To do this,
 * Follow the steps in xTIMEcomposer User Guide Chapter 20.
 *
 ************************************************************************************
 * REVISION HISTORY
 * Date:                Description:                      Changes by:        Version:
 * 13.04.2016           File created                      M.Ozcelikors       2.0.0
 * 16.04.2016           Revisions and addition of Servo   M.Ozcelikors       2.0.1
 *                      New run configurations
 ************************************************************************************/

// Includes  -------------------------------------------------------------------
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
#include <xtcp.h>
#include "servo.h"
// ---------------------------------------------------------------Includes------


// Defines ---------------------------------------------------------------------
// Steering Servo Related Defines
#define SERVO_PORT_WIDTH  1
on tile[0] : out port PortSteeringServo = XS1_PORT_1H;

// I2C Related Defines
#define I2C_SPEED_KBITPERSEC    ((unsigned) 10)  // ?? Check later
#define Task_MaintainI2CConnection i2c_master //Renaming i2c_master for more visual appeal

// I2C Related Ports
on tile[0] : port PortSCL = XS1_PORT_1E;
on tile[0] : port PortSDA = XS1_PORT_1F;

// UART Ports
on tile[0] : port PortUART_TX = XS1_PORT_1N;
on tile[0] : port PortUART_RX = XS1_PORT_1M;

// UART Related Defines
#define BAUD_RATE       115200
#define RX_BUFFER_SIZE  64

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

#pragma unsafe arrays
// ------------------------------------------------------------------Defines-----


// Interface Definitions --------------------------------------------------------
typedef interface distancesensor_if
{
    void ShareDistanceSensorValues (uint8_t left_sensor_value,
                                    uint8_t right_sensor_value,
                                    uint8_t front_sensor_value,
                                    uint8_t rear_sensor_value);
} distancesensor_if;

typedef interface control_if
{
    void ShareControlValue (uint8_t control_value);
    void ShareSteeringValue(uint8_t steering_value);
} control_if;

typedef interface steering_if
{
    void ShareSteeringValue (uint8_t steering_value);
} steering_if;
//------------------------------------------------------Interface Definitions----


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


// Task Functions  --------------------------------------------------------------
void Task_ReadSonarSensors(client i2c_master_if i2c_interface, client distancesensor_if sensors_interface)
{
    // One function could work with 4 instances, therefore 4 sensors

    // Declare some variables to use later
    i2c_regop_res_t result;
    uint8_t high_byte;
    uint8_t low_byte;
    unsigned acc; //accumulator for distance measurement
    uint8_t left, right, front, rear;

    while(1)
    {
        // Start messaging
        result = i2c_interface.write_reg(getDistanceSensorAddr(LEFT_DISTANCE_SENSOR_ID), 0x00, WRDATA_CENTIMETERS); //Left Sensor //Args: addr, reg, data
        if (result != I2C_REGOP_SUCCESS) {
            printf("I2C write reg failed\n");
        }
        delay_milliseconds(10);

        result = i2c_interface.write_reg(getDistanceSensorAddr(RIGHT_DISTANCE_SENSOR_ID), 0x00, WRDATA_CENTIMETERS); //Right Sensor //Args: addr, reg, data
        if (result != I2C_REGOP_SUCCESS) {
            printf("I2C write reg failed\n");
        }
        delay_milliseconds(10);

        result = i2c_interface.write_reg(getDistanceSensorAddr(FRONT_DISTANCE_SENSOR_ID), 0x00, WRDATA_CENTIMETERS); //Front Sensor //Args: addr, reg, data
        if (result != I2C_REGOP_SUCCESS) {
            printf("I2C write reg failed\n");
        }
        delay_milliseconds(10);

        result = i2c_interface.write_reg(getDistanceSensorAddr(REAR_DISTANCE_SENSOR_ID), 0x00, WRDATA_CENTIMETERS); //Rear Sensor //Args: addr, reg, data
        if (result != I2C_REGOP_SUCCESS) {
            printf("I2C write reg failed\n");
        }
        delay_milliseconds(20);


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
    }
}

// UART Application
void Task_GetRemoteCommandsViaBluetooth(client uart_tx_if i_tx,
                                        client uart_rx_if i_rx,
                                        client control_if control_interface,
                                        client steering_if steering_interface)
{

}

// Main processing, receiving end
void Task_ProduceMotorControlOutputs (server distancesensor_if sensors_interface,
                                      server control_if control_interface,
                                      server steering_if steering_interface)
{
    uint8_t left, right, front, rear;

    while(1)
    {
        select
        {
            case sensors_interface.ShareDistanceSensorValues (uint8_t left_sensor_value,
                                                              uint8_t right_sensor_value,
                                                              uint8_t front_sensor_value,
                                                              uint8_t rear_sensor_value):
                left = left_sensor_value;
                right = right_sensor_value;
                front = front_sensor_value;
                rear = rear_sensor_value;
                break;
        }

        printf("%d %d %d %d\n",left, right, front, rear);
    }
}

// PWM Application
void Task_DriveMotorsUsingPWM (server control_if control_interface,
                               server steering_if steering_interface)
{

}

// Steering Servo Demo, to be merged with main actuation task!!
void demo_servo (client interface servo_if i_servo) {
    timer tmr;
    unsigned int time, delay = 5000 * MICROSECOND;
    unsigned int i, j;

    tmr :> time;
    while (1) {
        printstrln("Going up!");
        for (i = SERVO_MIN_POS; i < SERVO_MAX_POS; i+= 100) {
            for (j = 0; j < SERVO_PORT_WIDTH; j++) {
                i_servo.set_pos(j, i);
            }
            tmr when timerafter(time + delay) :> time;
        }
        printstrln("Going down!");
        for (i = SERVO_MAX_POS; i > SERVO_MIN_POS; i-= 100) {
            tmr when timerafter(time + delay) :> time;
            for (j = 0; j < SERVO_PORT_WIDTH; j++) {
                i_servo.set_pos(j, i);
            }
            tmr when timerafter(time + delay) :> time;
        }
    }
    return;
}

//-------------------------------------------------------------Task Functions----


int main() {
  interface uart_rx_if i_rx;
  interface uart_tx_if i_tx;
  input_gpio_if i_gpio_rx;
  output_gpio_if i_gpio_tx[1];
  i2c_master_if i2c_client_device_instances[1];
  distancesensor_if sensors_interface;
  control_if control_interface;
  steering_if steering_interface;
  interface servo_if i_steering_servo;

  par {
     // UART TX Related Tasks
     on tile[0]:          output_gpio (i_gpio_tx, 1, PortUART_TX, null);
     on tile[0]:          uart_tx(i_tx, null, BAUD_RATE, UART_PARITY_NONE, 8, 1, i_gpio_tx[0]);

     // UART RX Related Tasks
     on tile[0].core[0] : input_gpio_1bit_with_events (i_gpio_rx, PortUART_RX);
     on tile[0].core[0] : uart_rx(i_rx, null, RX_BUFFER_SIZE, BAUD_RATE, UART_PARITY_NONE, 8, 1, i_gpio_rx);

     // I2C Task
     on tile[0] :         Task_MaintainI2CConnection(i2c_client_device_instances, 1, PortSCL, PortSDA, I2C_SPEED_KBITPERSEC);

     // Steering Servo Tasks
     on tile[0] : demo_servo(i_steering_servo); //Just a test app for now!!!
     on tile[0] : servo_task(i_steering_servo, PortSteeringServo, SERVO_PORT_WIDTH, SERVO_CENTRE_POS);

     //Other Tasks
     on tile[0] :         Task_ReadSonarSensors(i2c_client_device_instances[0], sensors_interface);
     on tile[0] :         Task_ProduceMotorControlOutputs(sensors_interface, control_interface, steering_interface);
     on tile[0] :         Task_GetRemoteCommandsViaBluetooth(i_tx, i_rx, control_interface, steering_interface);
  }

   return 0;
}

