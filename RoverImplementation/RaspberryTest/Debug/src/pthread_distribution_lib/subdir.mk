################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/pthread_distribution_lib/pthread_distribution.cpp 

OBJS += \
./src/pthread_distribution_lib/pthread_distribution.o 

CPP_DEPS += \
./src/pthread_distribution_lib/pthread_distribution.d 


# Each subdirectory must supply rules for building sources it contributes
src/pthread_distribution_lib/%.o: ../src/pthread_distribution_lib/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: Cross G++ Compiler'
	arm-linux-gnueabihf-g++ -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


