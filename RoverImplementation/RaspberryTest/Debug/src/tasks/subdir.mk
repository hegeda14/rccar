################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/tasks/display_sensors_task.cpp \
../src/tasks/infrared_distance_task.cpp \
../src/tasks/keycommand_task.cpp \
../src/tasks/motordriver_task.cpp \
../src/tasks/rover_test_task.cpp \
../src/tasks/temperature_task.cpp \
../src/tasks/ultrasonic_sensor_task.cpp 

OBJS += \
./src/tasks/display_sensors_task.o \
./src/tasks/infrared_distance_task.o \
./src/tasks/keycommand_task.o \
./src/tasks/motordriver_task.o \
./src/tasks/rover_test_task.o \
./src/tasks/temperature_task.o \
./src/tasks/ultrasonic_sensor_task.o 

CPP_DEPS += \
./src/tasks/display_sensors_task.d \
./src/tasks/infrared_distance_task.d \
./src/tasks/keycommand_task.d \
./src/tasks/motordriver_task.d \
./src/tasks/rover_test_task.d \
./src/tasks/temperature_task.d \
./src/tasks/ultrasonic_sensor_task.d 


# Each subdirectory must supply rules for building sources it contributes
src/tasks/%.o: ../src/tasks/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: Cross G++ Compiler'
	arm-linux-gnueabihf-g++ -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


