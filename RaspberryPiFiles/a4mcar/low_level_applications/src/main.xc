/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level Module Main File for connecting tasks using interfaces
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */
 /************************************************************************************
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
#include "ar8035_phy_driver.h"


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
     on tile[0]:          output_gpio (i_gpio_tx, 1, PortUART_TX, null);
     on tile[0]:          uart_tx(i_tx, null, BAUD_RATE, UART_PARITY_NONE, 8, 1, i_gpio_tx[0]);

     // UART RX Related Tasks
     on tile[0].core[0] : input_gpio_1bit_with_events (i_gpio_rx, PortUART_RX);
     on tile[0].core[0] : uart_rx(i_rx, null, RX_BUFFER_SIZE, BAUD_RATE, UART_PARITY_NONE, 8, 1, i_gpio_rx);

     // I2C Task
     on tile[0] : Task_MaintainI2CConnection(i2c_client_device_instances, 1, PortSCL, PortSDA, I2C_SPEED_KBITPERSEC);

     // Motor Speed Controller (PWM) Tasks
     on tile[0].core[4] :         Task_DriveTBLE02S_MotorController(PortMotorSpeedController, PortBRAKEctrl, control_interface, sensors_interface);

     // Steering Servo (PWM) Tasks
     on tile[0].core[4] :         Task_SteeringServo_MotorController (PortSteeringServo, steering_interface);

     //Light System Task
     on tile[0].core[7]:              Task_ControlLightSystem (PortLightSystem_TH, PortLightSystem_ST, lightstate_interface);

     // Other Tasks
     on tile[0] :           Task_ReadSonarSensors(i2c_client_device_instances[0], sensors_interface);
     on tile[0].core[1] :   Task_MainProcessingAndBluetoothControl(i_tx, i_rx, control_interface, steering_interface, i_cmd_from_ethernet_to_override, lightstate_interface);

     // Core Monitoring Tasks
     on tile[0]:                   Task_MonitorCoresInATile (core_stats_interface_tile0);
     on tile[1]:                   Task_MonitorCoresInATile (core_stats_interface_tile1);

     // Ethernet App Tasks
     on tile[1]: rgmii_ethernet_mac(i_eth_rx, NUM_ETH_CLIENTS, i_eth_tx, NUM_ETH_CLIENTS, null, null, c_rgmii_cfg, rgmii_ports, ETHERNET_DISABLE_SHAPER);
     on tile[1].core[0]: rgmii_ethernet_mac_config(i_eth_cfg, NUM_CFG_CLIENTS, c_rgmii_cfg);
     on tile[1].core[0]: Task_Ar8035_Phy_Driver (p_eth_reset, i_smi, i_eth_cfg[CFG_TO_PHY_DRIVER]);
     on tile[1]: smi(i_smi, p_smi_mdio, p_smi_mdc);

     on tile[0]: xtcp(c_xtcp, 1, null, i_eth_cfg[0], i_eth_rx[0], i_eth_tx[0], null, ETHERNET_SMI_PHY_ADDRESS, null, otp_ports, ipconfig);

     on tile[0]: Task_EthernetAppTCPServer(c_xtcp[0], i_cmd_from_ethernet_to_override, core_stats_interface_tile0, core_stats_interface_tile1);
  }


  // BAD UTILIZATION
  /*
  par {
       // UART TX Related Tasks
       on tile[0]:          output_gpio (i_gpio_tx, 1, PortUART_TX, null);
       on tile[0]:          uart_tx(i_tx, null, BAUD_RATE, UART_PARITY_NONE, 8, 1, i_gpio_tx[0]);

       // UART RX Related Tasks
       on tile[0].core[1] : input_gpio_1bit_with_events (i_gpio_rx, PortUART_RX);
       on tile[0].core[1] : uart_rx(i_rx, null, RX_BUFFER_SIZE, BAUD_RATE, UART_PARITY_NONE, 8, 1, i_gpio_rx);

       // I2C Task
       on tile[0] : Task_MaintainI2CConnection(i2c_client_device_instances, 1, PortSCL, PortSDA, I2C_SPEED_KBITPERSEC);

       // Motor Speed Controller (PWM) Tasks
       on tile[0].core[1] :         Task_DriveTBLE02S_MotorController(PortMotorSpeedController, control_interface, sensors_interface);

       // Steering Servo (PWM) Tasks
       on tile[0].core[1] :         Task_SteeringServo_MotorController (PortSteeringServo, steering_interface);

       //Light System Task
       on tile[0].core[1]:              Task_ControlLightSystem (PortLightSystem_TH, PortLightSystem_ST, lightstate_interface);

       // Other Tasks
       on tile[0] :           Task_ReadSonarSensors(i2c_client_device_instances[0], sensors_interface);
       on tile[0].core[1] :   Task_MainProcessingAndBluetoothControl(i_tx, i_rx, control_interface, steering_interface, i_cmd_from_ethernet_to_override, lightstate_interface);
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

