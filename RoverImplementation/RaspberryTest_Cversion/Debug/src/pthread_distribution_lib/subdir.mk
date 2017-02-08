################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/pthread_distribution_lib/pthread_distribution.c 

OBJS += \
./src/pthread_distribution_lib/pthread_distribution.o 

C_DEPS += \
./src/pthread_distribution_lib/pthread_distribution.d 


# Each subdirectory must supply rules for building sources it contributes
src/pthread_distribution_lib/%.o: ../src/pthread_distribution_lib/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: Cross GCC Compiler'
	arm-linux-gnueabihf-gcc -I"C:\rpi-eclipse\workspace\RaspberryTest\wiringPi" -I"C:\rpi-eclipse\workspace\RaspberryTest_Cversion\src" -I"C:\rpi-eclipse\workspace\RaspberryTest_Cversion\includes" -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


