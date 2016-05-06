/************************************************************************************
 * "Bluetooth Controlled RC-Car with Parking Feature using Multicore Technology"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @version 2.0.3
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
 * 23.04.2016           Ethernet v1 + File hierarchy      M.Ozcelikors       2.0.3
 ************************************************************************************/

#include "defines.h"
#include "rn42_driver.h"
#include "servo.h"
#include "sonar_sensor.h"
#include "tble02s_motor_controller.h"
#include "port_definitions.h"
#include "ethernet_app.h"

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

int main() {
  // Interface instances to be used
  interface uart_rx_if i_rx;
  interface uart_tx_if i_tx;
  input_gpio_if i_gpio_rx;
  output_gpio_if i_gpio_tx[1];
  i2c_master_if i2c_client_device_instances[1];
  distancesensor_if sensors_interface;
  control_if control_interface;
  steering_if steering_interface;

  // Ethernet app interface instances to be used
  chan c_xtcp[1];
  mii_if i_mii;
  smi_if i_smi;


  par {
     // UART TX Related Tasks
     on tile[0]:          output_gpio (i_gpio_tx, 1, PortUART_TX, null);
     on tile[0]:          uart_tx(i_tx, null, BAUD_RATE, UART_PARITY_NONE, 8, 1, i_gpio_tx[0]);

     // UART RX Related Tasks
     on tile[0].core[0] : input_gpio_1bit_with_events (i_gpio_rx, PortUART_RX);
     on tile[0].core[0] : uart_rx(i_rx, null, RX_BUFFER_SIZE, BAUD_RATE, UART_PARITY_NONE, 8, 1, i_gpio_rx);

     // I2C Task
     on tile[0] :         Task_MaintainI2CConnection(i2c_client_device_instances, 1, PortSCL, PortSDA, I2C_SPEED_KBITPERSEC);

     // Motor Speed Controller (PWM) Tasks
     on tile[0] :         Task_DriveTBLE02S_MotorController(PortMotorSpeedController, control_interface);

     // Steering Servo (PWM) Tasks
     on tile[0] :         Task_SteeringServo_MotorController (PortSteeringServo, steering_interface);

     //Other Tasks
     on tile[0] :         Task_ReadSonarSensors(i2c_client_device_instances[0], sensors_interface);
     on tile[0] :         Task_GetRemoteCommandsViaBluetooth(i_tx, i_rx, control_interface, steering_interface);
     on tile[0] :         Task_ProduceMotorControlOutputs (sensors_interface);

     // Ethernet App Tasks
     // MII/ethernet driver
     on tile[1]: mii(i_mii, p_eth_rxclk, p_eth_rxerr, p_eth_rxd, p_eth_rxdv,
                     p_eth_txclk, p_eth_txen, p_eth_txd, p_eth_timing,
                     eth_rxclk, eth_txclk, XTCP_MII_BUFSIZE) // The missing semicolon is intentional! This is a macro

     // SMI/ethernet phy driver
     on tile[1]: smi(i_smi, p_smi_mdio, p_smi_mdc);

     // TCP component
     on tile[1]: xtcp(c_xtcp, 1, i_mii,
                      null, null, null,
                      i_smi, ETHERNET_SMI_PHY_ADDRESS,
                      null, otp_ports, ipconfig);

     // The simple udp reflector thread
     on tile[1]: Task_EthernetAppUDPServer (c_xtcp[0]);
  }

   return 0;
}

