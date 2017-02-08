################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/RaspberryTest.c 

OBJS += \
./src/RaspberryTest.o 

C_DEPS += \
./src/RaspberryTest.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: Cross GCC Compiler'
	arm-linux-gnueabihf-gcc -I"C:\rpi-eclipse\workspace\RaspberryTest\wiringPi" -I"C:\rpi-eclipse\workspace\RaspberryTest_Cversion\src" -I"C:\rpi-eclipse\workspace\RaspberryTest_Cversion\includes" -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


