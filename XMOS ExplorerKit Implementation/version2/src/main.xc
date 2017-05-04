/************************************************************************************
 * "Multi-functional Multi-core RCCAR for APP4MC-platform Demonstration"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************
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
 * 20.05.2016           RGMII PHY Updated                 M.Ozcelikors       2.0.4
 * 19.06.2016           Ethernet commands are integrated  M.Ozcelikors       2.0.5
 *                      into system to override bluetooth
 *                      commands.
 * 22.11.2016           New update ---------------------- M.Ozcelikors       3.0.0
 *                      Light system, Lightweight TCP
 *                      implementation, Core monitoring,
 *                      itoa string library,
 *                      Core info sending over TCP added.
 ************************************************************************************/

#include "defines.h"
#include "rn42_driver.h"
#include "servo.h"
#include "sonar_sensor.h"
#include "tble02s_motor_controller.h"
#include "port_definitions.h"
#include "ethernet_app.h"
#include "ethernet_config.h"
#include "light_system.h"
#include "core_monitoring.h"
#include "core_debug.h"


/***
 *  PHY Driver For XCORE-200 EXPLORER KIT PHY
 */
[[combinable]]
 void ar8035_phy_driver(client interface smi_if smi,
         client interface ethernet_cfg_if eth) {
    PrintCoreAndTileInformation("ar8035_phy_driver");
    ethernet_link_state_t link_state = ETHERNET_LINK_DOWN;
    //RGMII version icin:
    //ethernet_speed_t link_speed = LINK_1000_MBPS_FULL_DUPLEX;
    //Non-RGMII version icin:
    ethernet_speed_t link_speed = LINK_100_MBPS_FULL_DUPLEX;
    const int phy_reset_delay_ms = 1;
    const int link_poll_period_ms = 1000;
    const int phy_address = 0x4;
    timer tmr;
    int t;
    tmr :> t;
    p_eth_reset <: 0;
    delay_milliseconds(phy_reset_delay_ms);
    p_eth_reset <: 1;

    while (smi_phy_is_powered_down(smi, phy_address));
    //RGMII version icin:
    //smi_configure(smi, phy_address, LINK_1000_MBPS_FULL_DUPLEX, SMI_ENABLE_AUTONEG);
    //Non-RGMII version icin:
    smi_configure(smi, phy_address, LINK_100_MBPS_FULL_DUPLEX, SMI_DISABLE_AUTONEG);

    while (1) {
        select {
        case tmr when timerafter(t) :> t:
            ethernet_link_state_t new_state = smi_get_link_state(smi, phy_address);
            // Read AR8035 status register bits 15:14 to get the current link speed
            if (new_state == ETHERNET_LINK_UP) {
                link_speed = (ethernet_speed_t)(smi.read_reg(phy_address, 0x11) >> 14) & 3;
            }
            if (new_state != link_state) {
                link_state = new_state;
                eth.set_link_state(0, new_state, link_speed);
            }
            t += link_poll_period_ms * XS1_TIMER_KHZ;
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
  core_stats_if core_stats_interface_tile0;
  core_stats_if core_stats_interface_tile1;
  lightstate_if lightstate_interface;

  // Ethernet app interface instances to be used
  chan c_xtcp[1];
  ethernet_cfg_if i_eth_cfg[NUM_CFG_CLIENTS];
  ethernet_rx_if i_eth_rx[NUM_ETH_CLIENTS];
  ethernet_tx_if i_eth_tx[NUM_ETH_CLIENTS];
  streaming chan c_rgmii_cfg;
  smi_if i_smi;
  ethernet_to_cmdparser_if i_cmd_from_ethernet_to_override;

  // GOOD UTILIZATION
  par {
     // UART TX Related Tasks
     on tile[0]:          output_gpio (i_gpio_tx, 1, PortUART_TX, null); //Core yok idi
     on tile[0]:          uart_tx(i_tx, null, BAUD_RATE, UART_PARITY_NONE, 8, 1, i_gpio_tx[0]);//Core yok idi

     // UART RX Related Tasks
     on tile[0].core[0] : input_gpio_1bit_with_events (i_gpio_rx, PortUART_RX);
     on tile[0].core[0] : uart_rx(i_rx, null, RX_BUFFER_SIZE, BAUD_RATE, UART_PARITY_NONE, 8, 1, i_gpio_rx);

     // I2C Task
     on tile[0] : Task_MaintainI2CConnection(i2c_client_device_instances, 1, PortSCL, PortSDA, I2C_SPEED_KBITPERSEC);

     // Motor Speed Controller (PWM) Tasks
     on tile[0].core[4] :         Task_DriveTBLE02S_MotorController(PortMotorSpeedController, PortBRAKEctrl, control_interface, sensors_interface);//Comb,Core yok idi

     // Steering Servo (PWM) Tasks
     on tile[0].core[4] :         Task_SteeringServo_MotorController (PortSteeringServo, steering_interface);//Comb,Core yok idi

     //Light System Task
     on tile[0].core[7]:              Task_ControlLightSystem (PortLightSystem_TH, PortLightSystem_ST, lightstate_interface);

     // Other Tasks
     on tile[0] :           Task_ReadSonarSensors(i2c_client_device_instances[0], sensors_interface);
     on tile[0].core[1] :   Task_GetRemoteCommandsViaBluetooth(i_tx, i_rx, control_interface, steering_interface, i_cmd_from_ethernet_to_override, lightstate_interface);
     //on tile[0] :         Task_ProduceMotorControlOutputs (sensors_interface);

     // Core Monitoring Tasks
     on tile[0]:                   Task_MonitorCoresInATile (core_stats_interface_tile0);
     on tile[1]:                   Task_MonitorCoresInATile (core_stats_interface_tile1);

     // Ethernet App Tasks
     on tile[1]: rgmii_ethernet_mac(i_eth_rx, NUM_ETH_CLIENTS, i_eth_tx, NUM_ETH_CLIENTS, null, null, c_rgmii_cfg, rgmii_ports, ETHERNET_DISABLE_SHAPER);
     on tile[1].core[0]: rgmii_ethernet_mac_config(i_eth_cfg, NUM_CFG_CLIENTS, c_rgmii_cfg);
     on tile[1].core[0]: ar8035_phy_driver(i_smi, i_eth_cfg[CFG_TO_PHY_DRIVER]);
     on tile[1]: smi(i_smi, p_smi_mdio, p_smi_mdc);

     on tile[0]: xtcp(c_xtcp, 1, null, i_eth_cfg[0], i_eth_rx[0], i_eth_tx[0], null, ETHERNET_SMI_PHY_ADDRESS, null, otp_ports, ipconfig);

     on tile[0]: Task_EthernetAppTCPServer(c_xtcp[0], i_cmd_from_ethernet_to_override, core_stats_interface_tile0, core_stats_interface_tile1);
  }


  // BAD UTILIZATION
  /*
  par {
       // UART TX Related Tasks
       on tile[0]:          output_gpio (i_gpio_tx, 1, PortUART_TX, null); //Core yok idi
       on tile[0]:          uart_tx(i_tx, null, BAUD_RATE, UART_PARITY_NONE, 8, 1, i_gpio_tx[0]);//Core yok idi

       // UART RX Related Tasks
       on tile[0].core[1] : input_gpio_1bit_with_events (i_gpio_rx, PortUART_RX);
       on tile[0].core[1] : uart_rx(i_rx, null, RX_BUFFER_SIZE, BAUD_RATE, UART_PARITY_NONE, 8, 1, i_gpio_rx);

       // I2C Task
       on tile[0] : Task_MaintainI2CConnection(i2c_client_device_instances, 1, PortSCL, PortSDA, I2C_SPEED_KBITPERSEC);

       // Motor Speed Controller (PWM) Tasks
       on tile[0].core[1] :         Task_DriveTBLE02S_MotorController(PortMotorSpeedController, control_interface, sensors_interface);//Comb,Core yok idi

       // Steering Servo (PWM) Tasks
       on tile[0].core[1] :         Task_SteeringServo_MotorController (PortSteeringServo, steering_interface);//Comb,Core yok idi

       //Light System Task
       on tile[0].core[1]:              Task_ControlLightSystem (PortLightSystem_TH, PortLightSystem_ST, lightstate_interface);

       // Other Tasks
       on tile[0] :           Task_ReadSonarSensors(i2c_client_device_instances[0], sensors_interface);
       on tile[0].core[1] :   Task_GetRemoteCommandsViaBluetooth(i_tx, i_rx, control_interface, steering_interface, i_cmd_from_ethernet_to_override, lightstate_interface);
       //on tile[0] :         Task_ProduceMotorControlOutputs (sensors_interface);

       // Core Monitoring Tasks
       on tile[0]:                   Task_MonitorCoresInATile (core_stats_interface_tile0);
       on tile[1]:                   Task_MonitorCoresInATile (core_stats_interface_tile1);

       // Ethernet App Tasks
       on tile[1]: rgmii_ethernet_mac(i_eth_rx, NUM_ETH_CLIENTS, i_eth_tx, NUM_ETH_CLIENTS, null, null, c_rgmii_cfg, rgmii_ports, ETHERNET_DISABLE_SHAPER);
       on tile[1].core[1]: rgmii_ethernet_mac_config(i_eth_cfg, NUM_CFG_CLIENTS, c_rgmii_cfg);
       on tile[1].core[1]: ar8035_phy_driver(i_smi, i_eth_cfg[CFG_TO_PHY_DRIVER]);
       on tile[1]: smi(i_smi, p_smi_mdio, p_smi_mdc);

       on tile[0]: xtcp(c_xtcp, 1, null, i_eth_cfg[0], i_eth_rx[0], i_eth_tx[0], null, ETHERNET_SMI_PHY_ADDRESS, null, otp_ports, ipconfig);

       on tile[0]: Task_EthernetAppTCPServer(c_xtcp[0], i_cmd_from_ethernet_to_override, core_stats_interface_tile0, core_stats_interface_tile1);
    }
    */

   return 0;
}

