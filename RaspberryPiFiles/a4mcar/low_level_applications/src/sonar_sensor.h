/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Low-level Module SRF02 Sonar Sensor driver functions and driving task - Header file
 *
 * Authors:
 *    M. Ozcelikors <mozcelikors@gmail.com>
 *
 * Update History:
 *
 */

#ifndef SONAR_SENSOR_H_
#define SONAR_SENSOR_H_

#include "defines.h"

// I2C Related Defines
#define I2C_SPEED_KBITPERSEC    ((unsigned) 10)  // I2C speed
#define Task_MaintainI2CConnection i2c_master    // Renaming library function i2c_master

// Distance sensor related Defines
#define SENSOR_READ_PERIOD              (200 * MILLISECOND)

#define WRDATA_CENTIMETERS              ((uint8_t)0x51)

#define LEFT_DISTANCE_SENSOR_ID         0
#define RIGHT_DISTANCE_SENSOR_ID        1
#define FRONT_DISTANCE_SENSOR_ID        2
#define REAR_DISTANCE_SENSOR_ID         3

#define LEFT_DISTANCE_SENSOR_DEVICEADDR     ((uint8_t) 0x7A)
#define RIGHT_DISTANCE_SENSOR_DEVICEADDR    ((uint8_t) 0x7B)
#define FRONT_DISTANCE_SENSOR_DEVICEADDR    ((uint8_t) 0x7C)
#define REAR_DISTANCE_SENSOR_DEVICEADDR     ((uint8_t) 0x79)

// Prototypes
uint8_t getDistanceSensorAddr (int sensor_id);
void Task_ReadSonarSensors(client i2c_master_if i2c_interface, client distancesensor_if sensors_interface);
int InitializeMessaging (client i2c_master_if i2c_interface);

#endif /* SONAR_SENSOR_H_ */
