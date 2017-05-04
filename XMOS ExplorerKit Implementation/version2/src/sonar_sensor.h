/************************************************************************************
 * "Multi-functional Multi-core RCCAR for APP4MC-platform Demonstration"
 * Low Level Software
 * For xCORE-200 / XE-216 Devices
 * All rights belong to PIMES, FH Dortmund
 * Supervisor: Robert Hottger
 * @author Mustafa Ozcelikors
 * @contact mozcelikors@gmail.com
 ************************************************************************************/

#ifndef SONAR_SENSOR_H_
#define SONAR_SENSOR_H_

#include "defines.h"

// I2C Related Defines
#define I2C_SPEED_KBITPERSEC    ((unsigned) 10)  // ?? Check later
#define Task_MaintainI2CConnection i2c_master //Renaming i2c_master for more visual appeal

// Distance sensor related Defines
#define SENSOR_READ_PERIOD              (200 * MILLISECOND) //800 idi


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
