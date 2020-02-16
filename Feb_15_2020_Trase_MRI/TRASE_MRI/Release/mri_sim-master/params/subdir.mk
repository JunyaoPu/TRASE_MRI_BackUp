################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CU_SRCS += \
../mri_sim-master/params/TRASE_Params.cu \
../mri_sim-master/params/simuParams.cu 

OBJS += \
./mri_sim-master/params/TRASE_Params.o \
./mri_sim-master/params/simuParams.o 

CU_DEPS += \
./mri_sim-master/params/TRASE_Params.d \
./mri_sim-master/params/simuParams.d 


# Each subdirectory must supply rules for building sources it contributes
mri_sim-master/params/%.o: ../mri_sim-master/params/%.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/usr/local/cuda-9.1/bin/nvcc -I/usr/local/cuda/lib64/ -I/home/graphics/Dev/external_sources/cub-1.7.4 -I/home/junyao/Documents/cub-1.7.4 -O3 -std=c++11 -gencode arch=compute_61,code=sm_61  -odir "mri_sim-master/params" -M -o "$(@:%.o=%.d)" "$<"
	/usr/local/cuda-9.1/bin/nvcc -I/usr/local/cuda/lib64/ -I/home/graphics/Dev/external_sources/cub-1.7.4 -I/home/junyao/Documents/cub-1.7.4 -O3 -std=c++11 --compile --relocatable-device-code=true -gencode arch=compute_61,code=compute_61 -gencode arch=compute_61,code=sm_61  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


