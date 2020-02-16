################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir.mk
-include mri_sim-master/util/subdir.mk
-include mri_sim-master/sequence/subdir.mk
-include mri_sim-master/scanner/subdir.mk
-include mri_sim-master/primitives/subdir.mk
-include mri_sim-master/params/subdir.mk
-include mri_sim-master/kernels/subdir.mk
-include mri_sim-master/coil/subdir.mk
-include mri_sim-master/blochdiff/subdir.mk
-include mri_sim-master/acquisition/subdir.mk
-include mri_sim-master/Release/util/subdir.mk
-include mri_sim-master/Release/sequence/subdir.mk
-include mri_sim-master/Release/scanner/subdir.mk
-include mri_sim-master/Release/primitives/subdir.mk
-include mri_sim-master/Release/params/subdir.mk
-include mri_sim-master/Release/kernels/subdir.mk
-include mri_sim-master/Release/subdir.mk
-include mri_sim-master/Release/coil/subdir.mk
-include mri_sim-master/Release/blochdiff/subdir.mk
-include mri_sim-master/Release/acquisition/subdir.mk
-include mri_sim-master/subdir.mk
-include mri_sim-master/Debug/util/subdir.mk
-include mri_sim-master/Debug/sequence/subdir.mk
-include mri_sim-master/Debug/scanner/subdir.mk
-include mri_sim-master/Debug/primitives/subdir.mk
-include mri_sim-master/Debug/params/subdir.mk
-include mri_sim-master/Debug/kernels/subdir.mk
-include mri_sim-master/Debug/subdir.mk
-include mri_sim-master/Debug/coil/subdir.mk
-include mri_sim-master/Debug/blochdiff/subdir.mk
-include mri_sim-master/Debug/acquisition/subdir.mk

OS_SUFFIX := $(subst Linux,linux,$(subst Darwin/x86_64,darwin,$(shell uname -s)/$(shell uname -m)))

-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(CC_DEPS)),)
-include $(CC_DEPS)
endif
ifneq ($(strip $(C++_DEPS)),)
-include $(C++_DEPS)
endif
ifneq ($(strip $(C_UPPER_DEPS)),)
-include $(C_UPPER_DEPS)
endif
ifneq ($(strip $(CXX_DEPS)),)
-include $(CXX_DEPS)
endif
ifneq ($(strip $(CU_DEPS)),)
-include $(CU_DEPS)
endif
ifneq ($(strip $(CPP_DEPS)),)
-include $(CPP_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# OpenGL+GLUT OS-specific define
ifeq ($(shell uname -s),Darwin)
GLUT_LIBS := -Xlinker -framework -Xlinker GLUT -Xlinker -framework -Xlinker OpenGL
else
GLUT_LIBS := -lGL -lGLU -lglut 
endif


# Add inputs and outputs from these tool invocations to the build variables 

# All Target
all: TRASE_MRI

# Tool invocations
TRASE_MRI: $(OBJS) $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: NVCC Linker'
	/usr/local/cuda-9.1/bin/nvcc --cudart static --relocatable-device-code=true -gencode arch=compute_61,code=compute_61 -gencode arch=compute_61,code=sm_61 -link -o  "TRASE_MRI" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(CC_DEPS)$(C++_DEPS)$(EXECUTABLES)$(C_UPPER_DEPS)$(CXX_DEPS)$(OBJS)$(CU_DEPS)$(CPP_DEPS)$(C_DEPS) TRASE_MRI
	-@echo ' '

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
