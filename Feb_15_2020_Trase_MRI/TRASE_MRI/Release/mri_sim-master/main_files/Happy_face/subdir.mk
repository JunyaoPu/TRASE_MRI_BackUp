################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CU_SRCS += \
../mri_sim-master/main_files/Happy_face/happy_face.cu 

OBJS += \
./mri_sim-master/main_files/Happy_face/happy_face.o 

CU_DEPS += \
./mri_sim-master/main_files/Happy_face/happy_face.d 


# Each subdirectory must supply rules for building sources it contributes
mri_sim-master/main_files/Happy_face/%.o: ../mri_sim-master/main_files/Happy_face/%.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/usr/local/cuda-9.1/bin/nvcc -O3 -gencode arch=compute_61,code=sm_61  -odir "mri_sim-master/main_files/Happy_face" -M -o "$(@:%.o=%.d)" "$<"
	/usr/local/cuda-9.1/bin/nvcc -O3 --compile --relocatable-device-code=true -gencode arch=compute_61,code=compute_61 -gencode arch=compute_61,code=sm_61  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


