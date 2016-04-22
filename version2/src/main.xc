/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @version 2.0.2
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
 * 22.04.2016           PWM & Motor Speed Control v1      M.Ozcelikors       2.0.2
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
// ---------------------------------------------------------------Includes------


// Defines ---------------------------------------------------------------------

#define MICROSECOND             (XS1_TIMER_HZ / 1000000)
#define MILLISECOND             (1000 * MICROSECOND)

// Motor Speed Controller Defines
on tile[0] : port PortMotorSpeedController = XS1_PORT_1K; //J12

#define TBLE02S_FWD_MINSPEED_PULSE_WIDTH    (1.47 * MILLISECOND)
#define TBLE02S_FWD_MAXSPEED_PULSE_WIDTH    (1.15 * MILLISECOND)
#define TBLE02S_REV_MINSPEED_PULSE_WIDTH    (1.58 * MILLISECOND)
#define TBLE02S_REV_MAXSPEED_PULSE_WIDTH    (1.87 * MILLISECOND)
#define TBLE02S_PWM_PERIOD                  (20 * MILLISECOND)

#define FORWARD     0
#define REVERSE     1

// Steering Servo Related Defines
on tile[0] : out port PortSteeringServo = XS1_PORT_1H; //J13

#define     STEERINGSERVO_PWM_PERIOD                (20 * MILLISECOND)
#define     STEERINGSERVO_PWM_MAXLEFT_PULSE_WIDTH   (1.3 * MILLISECOND)
#define     STEERINGSERVO_PWM_MAXRIGHT_PULSE_WIDTH  (1.75 * MILLISECOND)

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
#define SENSOR_READ_PERIOD              (800 * MILLISECOND)

#define WRDATA_CENTIMETERS              ((uint8_t)0x51)

#define LEFT_DISTANCE_SENSOR_ID         0
#define RIGHT_DISTANCE_SENSOR_ID        1
#define FRONT_DISTANCE_SENSOR_ID        2
#define REAR_DISTANCE_SENSOR_ID         3

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
    void ShareDirectionValue (int direction);
    void ShareSpeedValue (int speed_value);
} control_if;

typedef interface steering_if
{
    void ShareSteeringValue (int  steering_val);
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

// ----- Task Functions  --------------------------------------------------------
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

    tmr3 :> time3;
    while (1) {
        select
        {
            case tmr3 when timerafter(time3) :> void :
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
                printf("x\n");

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
                printf("y\n");

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
                printf("z\n");

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
                break;
        }
    }
}

/***
 *  Function Name:              Task_GetRemoteCommandsViaBluetooth
 *  Function Description :      This function communicates with Bluetooth module via UART to obtain
 *                              control interface and steering_inferface values
 *
 *  Argument                Type                        Description
 *  control_interface       client control_if           Motor speed control value (high level)
 *  steering_interface      client steering_if          Steering control value (high level)
 *  i_tx                    client uart_tx_if           UART TX Interface
 *  i_rx                    client uart_rx_if           UART RX Interface
 */
void Task_GetRemoteCommandsViaBluetooth(client uart_tx_if i_tx,
                                        client uart_rx_if i_rx,
                                        client control_if control_interface,
                                        client steering_if steering_interface)
{
    timer tmr2;
    unsigned int time2, delay2 = 4000 * MILLISECOND; //4sec
    int set_val = 0;
    int direction_val = REVERSE;
    int speed_val = 0;

    tmr2 :> time2;
    while (1) {
        select
        {
            case tmr2 when timerafter(time2) :> void :
                steering_interface.ShareSteeringValue(set_val);
                control_interface.ShareDirectionValue(direction_val);
                control_interface.ShareSpeedValue(speed_val);
                time2 += delay2;

                //Toggle to other set value for testing
                if(set_val == 0)
                {
                    set_val = 50;
                    speed_val = 0;
                }
                else if(set_val == 50)
                {
                    set_val = 0;
                    speed_val = 10;
                }

                break;
        }
    }
}

/***
 *  Function Name:              Task_ProduceMotorControlOutputs
 *  Function Description :      This function uses distance sensor values and motor control values
 *                              in order to produce low level outputs to drive motors
 *
 *  Argument                Type                        Description
 *  control_interface       server control_if           Motor speed control value (high level)
 *  steering_interface      server steering_if          Steering control value (high level)
 *  sensors_interface       server distancesensor_if    Used to obtain distance sensor values
 */
void Task_ProduceMotorControlOutputs (server distancesensor_if sensors_interface)
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

//-------------------------------------------------------------Task Functions----

/***
 *  Function Name:              Task_ApplyPWMTo1BitPort
 *  Function Description :      This function can be used to apply PWM signal to a 1-bit port.
 *                              The default period can be changed by the varialbe overall_pwm_period,
 *                              keeping in mind that 100MHz clock results that 100000 timer ticks mean
 *                              1 millisecond.
 *
 *  Argument       Type           Description
 *  p              port           1-bit port to have pwm output
 *  duty_cycle     int            duty cycle percentage (0-100)
 */
// The following function is not used in our application, but is created as a pwm reference
void Task_ApplyPWMTo1BitPort (port p, int duty_cycle) // int duty_cycle later to be declared as server
{
    uint32_t overall_pwm_period = 2 * MILLISECOND; //2ms
    uint32_t on_period  =   (duty_cycle * overall_pwm_period * (1.0/100));
    uint32_t off_period =   overall_pwm_period - on_period;
    printf("%d %d", on_period, off_period);

    uint32_t    time;
    int         port_state = 0;
    timer       tmr;

    tmr :> time;

    while(1)
    {
        select
        {
            case tmr when timerafter(time) :> void :
                //Toggle
                if(port_state == 0)
                {
                    p <: 1;
                    port_state = 1;
                    time += on_period; //Extend timer deadline
                }
                else if(port_state == 1)
                {
                    p <: 0;
                    port_state = 0;
                    time += off_period; //Extend timer deadline
                }

                break;
        }
    }
}

/***
 *  Function Name:              Task_SteeringServo_MotorController
 *  Function Description :      Generates the appropriote PWM to the servo to drive it.
 *
 *  Argument            Type           Description
 *  p                   port           1-bit port to have pwm output
 *  steering_interface  steering_if    0-> MOST RIGHT  100-> MOST LEFT
 */
void Task_SteeringServo_MotorController (out port p, server steering_if steering_interface)
{
    uint32_t overall_pwm_period = STEERINGSERVO_PWM_PERIOD;
    uint32_t on_period;
    uint32_t off_period;

    uint32_t time;
    int port_state = 0;
    timer tmr;

    int steering;

    while (1)
    {
        select
        {
            //Wait for the steering value
            case steering_interface.ShareSteeringValue (int steering_val):
                steering = steering_val;
                break;

            //Calculate PWM periods and apply period within the timer
            case tmr when timerafter(time) :> void :
                tmr :> time;

                if  (steering == 0)
                {
                    on_period = STEERINGSERVO_PWM_MAXLEFT_PULSE_WIDTH;
                }
                else if (steering > 100)
                {
                    on_period = STEERINGSERVO_PWM_MAXRIGHT_PULSE_WIDTH;
                }
                else
                {
                    on_period = (STEERINGSERVO_PWM_MAXLEFT_PULSE_WIDTH + ((STEERINGSERVO_PWM_MAXRIGHT_PULSE_WIDTH - STEERINGSERVO_PWM_MAXLEFT_PULSE_WIDTH) * (steering/100.0)));
                }

                off_period = overall_pwm_period - on_period;

                //PWM Port Toggling
                if(port_state == 0)
                {
                    p <: 1;
                    port_state = 1;
                    time += on_period; //Extend timer deadline
                }
                else if(port_state == 1)
                {
                    p <: 0;
                    port_state = 0;
                    time += off_period; //Extend timer deadline
                }

                break;

        }
    }
}

/***
 *  Function Name:              Task_DriveTBLE02S_MotorController
 *  Function Description :      Generates the appropriote PWM to the motors to drive the TBLE02S Motor
 *
 *  Argument       Type           Description
 *  p              port           1-bit port to have pwm output
 *  control_interface             direction + speed
 *  direction      int            FORWARD (0) or REVERSE (1)
 *  speed          int            0-100
 */
void Task_DriveTBLE02S_MotorController (port p, server control_if control_interface)
{
    uint32_t overall_pwm_period = TBLE02S_PWM_PERIOD ; //20ms
    uint32_t on_period ;
    uint32_t off_period ;

    uint32_t    time;
    int         port_state = 0;
    timer       tmr;

    int direction_val = FORWARD;
    int speed_val = 0;

    while(1)
    {
        select
        {
            //Wait for the direction value
            case control_interface.ShareDirectionValue (int direction):
                direction_val = direction;
                break;

            //Wait for the speed value
            case control_interface.ShareSpeedValue (int speed):
                speed_val = speed;
                break;

            //Calculate PWM periods and apply period within the timer
            case tmr when timerafter(time) :> void :
                tmr :> time;

                if (direction_val == FORWARD) //Forward speed 0-100 mapping to on period
                {
                   if (speed_val == 0)
                   {
                       on_period = TBLE02S_FWD_MINSPEED_PULSE_WIDTH;
                   }
                   else if (speed_val > 100)
                   {
                       on_period = TBLE02S_FWD_MAXSPEED_PULSE_WIDTH;
                   }
                   else
                   {
                       on_period = (TBLE02S_FWD_MINSPEED_PULSE_WIDTH - ((TBLE02S_FWD_MINSPEED_PULSE_WIDTH - TBLE02S_FWD_MAXSPEED_PULSE_WIDTH) * (speed_val/100.0)));
                       //printf("on_period : %d", on_period);
                   }

                   off_period = overall_pwm_period - on_period;
                }
                else if (direction_val == REVERSE) //Reverse speed 0-100 mapping to on period
                {
                   if (speed_val == 0)
                   {
                       on_period = TBLE02S_REV_MINSPEED_PULSE_WIDTH;
                   }
                   else if (speed_val > 100)
                   {
                       on_period = TBLE02S_REV_MAXSPEED_PULSE_WIDTH;
                   }
                   else
                   {
                       on_period = (TBLE02S_REV_MINSPEED_PULSE_WIDTH + ((TBLE02S_REV_MAXSPEED_PULSE_WIDTH - TBLE02S_REV_MINSPEED_PULSE_WIDTH) * (speed_val/100.0)));
                       //printf("on_period : %d", on_period);
                   }

                   off_period = overall_pwm_period - on_period;
                }


                //PWM Port Toggling
                if(port_state == 0)
                {
                    p <: 1;
                    port_state = 1;
                    time += on_period; //Extend timer deadline
                }
                else if(port_state == 1)
                {
                    p <: 0;
                    port_state = 0;
                    time += off_period; //Extend timer deadline
                }

                break;
        }
    }
}

int main() {
  interface uart_rx_if i_rx;
  interface uart_tx_if i_tx;
  input_gpio_if i_gpio_rx;
  output_gpio_if i_gpio_tx[1];
  i2c_master_if i2c_client_device_instances[1];
  distancesensor_if sensors_interface;
  control_if control_interface;
  steering_if steering_interface;


  par {
     // UART TX Related Tasks
     //on tile[0]:          output_gpio (i_gpio_tx, 1, PortUART_TX, null);
     //on tile[0]:          uart_tx(i_tx, null, BAUD_RATE, UART_PARITY_NONE, 8, 1, i_gpio_tx[0]);

     // UART RX Related Tasks
     //on tile[0].core[0] : input_gpio_1bit_with_events (i_gpio_rx, PortUART_RX);
     //on tile[0].core[0] : uart_rx(i_rx, null, RX_BUFFER_SIZE, BAUD_RATE, UART_PARITY_NONE, 8, 1, i_gpio_rx);

     // I2C Task
     on tile[0] :         Task_MaintainI2CConnection(i2c_client_device_instances, 1, PortSCL, PortSDA, I2C_SPEED_KBITPERSEC);

     // Motor Speed Controller (PWM) Tasks
     on tile[0] :         Task_DriveTBLE02S_MotorController(PortMotorSpeedController, control_interface);

     // Steering Servo (PWM) Tasks
     on tile[0] :         Task_SteeringServo_MotorController (PortSteeringServo, steering_interface);

     //Other Tasks
     on tile[0] :         Task_ReadSonarSensors(i2c_client_device_instances[0], sensors_interface);
     on tile[0] :         Task_GetRemoteCommandsViaBluetooth(i_tx, i_rx, control_interface, steering_interface);

     on tile[0]:           Task_ProduceMotorControlOutputs (sensors_interface);
  }

   return 0;
}

