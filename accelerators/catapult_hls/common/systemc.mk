include ../../common/common.mk

ifeq ("$(CATAPULT_PATH)", "")
$(error please define CATAPULT_PATH required for Catapult HLS library headers)
endif

#ifeq ("$(MGC_HOME)", "")
#$(error please define MGC_HOME required for Catapult HLS library headers)
#endif

ifeq ("$(SYSTEMC)", "")
$(error please define SYSTEMC to execute a standalone simulation)
endif

ifeq ("$(DMA_WIDTH)", "")
$(error please define the desired DMA_WIDTH for simulation)
endif

INCDIR ?=
INCDIR += -I../src
INCDIR += -I../tb
INCDIR += -I$(SYSTEMC)/include
#INCDIR += -I$(CATAPULT_PATH)/shared/include
INCDIR += -I$(MGC_HOME)/shared/include
INCDIR += -I$(ESP_ROOT)/accelerators/catapult_hls/common/syn-templates

CXXFLAGS ?=
CXXFLAGS += -g
CXXFLAGS += $(INCDIR)
CXXFLAGS += -DDMA_WIDTH=$(DMA_WIDTH)
CXXFLAGS += -DCLOCK_PERIOD=10000
CXXFLAGS += -D__CUSTOM_SIM__
CXXFLAGS += -D__MNTR_CONNECTIONS__
CXXFLAGS += -DHLS_CATAPULT
CXXFLAGS += -std=c++11
CXXFLAGS += -Wno-unknown-pragmas
CXXFLAGS += -Wno-unused-variable
CXXFLAGS += -Wno-unused-label
CXXFLAGS += -Wall
#CXXFLAGS += -DDMA_SINGLE_PROCESS

LDLIBS :=
LDLIBS += -L$(MGC_HOME)/shared/lib
#LDLIBS += -L$(CATAPULT_PATH)/shared/lib

LDFLAGS :=
LDFLAGS += -lsystemc
LDFLAGS += -lpthread

TARGET = $(ACCELERATOR)

VPATH ?=
VPATH += ../src
VPATH += ../tb
#VPATH += $(ESP_ROOT)/accelerators/catapult_hls/common/syn-templates/core/systems


SRCS :=
SRCS += $(foreach s, $(wildcard ../src/*.cpp) $(wildcard ../tb/*.cpp), $(shell basename $(s)))
#SRCS += $(foreach s, $(wildcard $(ESP_ROOT)/accelerators/catapult_hls/common/syn-templates/core/systems/*.cpp), $(shell basename $(s)))

OBJS := $(SRCS:.cpp=.o)

HDRS := $(wildcard ../src/*.hpp) $(wildcard ../tb/*.hpp)


all: $(TARGET)

.SUFFIXES: .cpp .hpp .o

$(OBJS): $(HDRS)

$(TARGET): $(OBJS)
	$(QUIET_LINK)$(CXX) -o $@ $^ ${LDFLAGS} ${LDLIBS}

.cpp.o:
	$(QUIET_CXX)$(CXX) $(CXXFLAGS) ${INCDIR} -c $< -o $@

run: $(TARGET)
	$(QUIET_RUN) LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(SYSTEMC)/lib-linux64 ./$< $(RUN_ARGS)

clean:
	$(QUIET_CLEAN)rm -f *.o $(TARGET)

.PHONY: all clean run