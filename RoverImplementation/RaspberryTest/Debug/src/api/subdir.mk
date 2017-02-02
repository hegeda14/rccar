################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/api/basic_psys_rover.c 

OBJS += \
./src/api/basic_psys_rover.o 

C_DEPS += \
./src/api/basic_psys_rover.d 


# Each subdirectory must supply rules for building sources it contributes
src/api/%.o: ../src/api/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: Cross GCC Compiler'
	arm-linux-gnueabihf-gcc -I"C:\rpi-eclipse\workspace\RaspberryTest\wiringPi" -I"C:\rpi-eclipse\workspace\RaspberryTest\src" -I"C:\rpi-eclipse\workspace\RaspberryTest\includes" -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


