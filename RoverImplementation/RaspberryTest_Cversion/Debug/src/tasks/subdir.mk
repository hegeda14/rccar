################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/tasks/display_sensors_task.c \
../src/tasks/infrared_distance_task.c \
../src/tasks/keycommand_task.c \
../src/tasks/motordriver_task.c \
../src/tasks/rover_test_task.c \
../src/tasks/temperature_task.c \
../src/tasks/ultrasonic_sensor_task.c 

OBJS += \
./src/tasks/display_sensors_task.o \
./src/tasks/infrared_distance_task.o \
./src/tasks/keycommand_task.o \
./src/tasks/motordriver_task.o \
./src/tasks/rover_test_task.o \
./src/tasks/temperature_task.o \
./src/tasks/ultrasonic_sensor_task.o 

C_DEPS += \
./src/tasks/display_sensors_task.d \
./src/tasks/infrared_distance_task.d \
./src/tasks/keycommand_task.d \
./src/tasks/motordriver_task.d \
./src/tasks/rover_test_task.d \
./src/tasks/temperature_task.d \
./src/tasks/ultrasonic_sensor_task.d 


# Each subdirectory must supply rules for building sources it contributes
src/tasks/%.o: ../src/tasks/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: Cross GCC Compiler'
	arm-linux-gnueabihf-gcc -I"C:\rpi-eclipse\workspace\RaspberryTest\wiringPi" -I"C:\rpi-eclipse\workspace\RaspberryTest_Cversion\src" -I"C:\rpi-eclipse\workspace\RaspberryTest_Cversion\includes" -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


