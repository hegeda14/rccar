################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/basic_psys_rover.c 

CPP_SRCS += \
../src/RaspberryTest.cpp \
../src/pthread_distribution.cpp \
../src/rover_test_task.cpp \
../src/temperature_task.cpp \
../src/ultrasonic_sensor_task.cpp 

OBJS += \
./src/RaspberryTest.o \
./src/basic_psys_rover.o \
./src/pthread_distribution.o \
./src/rover_test_task.o \
./src/temperature_task.o \
./src/ultrasonic_sensor_task.o 

C_DEPS += \
./src/basic_psys_rover.d 

CPP_DEPS += \
./src/RaspberryTest.d \
./src/pthread_distribution.d \
./src/rover_test_task.d \
./src/temperature_task.d \
./src/ultrasonic_sensor_task.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: Cross G++ Compiler'
	arm-linux-gnueabihf-g++ -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: Cross GCC Compiler'
	arm-linux-gnueabihf-gcc -I"C:\rpi-eclipse\workspace\RaspberryTest\wiringPi" -I"C:\rpi-eclipse\workspace\RaspberryTest\src" -I"C:\rpi-eclipse\workspace\RaspberryTest\includes" -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


