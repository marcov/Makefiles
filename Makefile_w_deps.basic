#################################################################################
#                   Very basic Makefile with dependencies                       #
#                         (C) Marco Vedovati, 2016                              #
#################################################################################

PROJECT_NAME := $(shell basename ${PWD})

DEBUG_LEVEL  := Debug

# Specify a cross-compiler prefix if needed
CROSS_PREFIX := 

################################################################################

DEBUG_LEVEL_LIST := Debug Release


ifeq ($(filter $(DEBUG_LEVEL),$(DEBUG_LEVEL_LIST)),)
    $(error Invalid DEBUG_LEVEL value '$(DEBUG_LEVEL)'. Supported values: '$(DEBUG_LEVEL_LIST)')
endif

################################################################################
# Note: VPATH is a standard Makefile variable,
# specifying a list of directories that make should search.
VPATH := .

CC := $(CROSS_PREFIX)gcc
CFLAGS_WARN   = -Wall -Werror -Wextra -Wundef 
CFLAGS        = $(CFLAGS_WARN) -c -g -ggdb 
AT            = @
BUILD_OBJ_DIR = build
DEPFLAGS      = -MMD -MP

ifeq ($(DEBUG_LEVEL),Debug)
    CFLAGS += -O0 -g -ggdb
    STRIP_CMD  = cp
    STRIP_OPTS =
else
    CFLAGS += -Ofast
    STRIP_CMD  = $(CROSS_PREFIX)strip
    STRIP_OPTS = -s -o
endif

# Including the same paths used for source lookup. Add more as needed...
INCDIRS =  \
  $(VPATH)

#################################################################################
#

# Auto-generating CC -I list
CFLAGS  += $(foreach dir,$(INCDIRS),-I$(dir) )

# Define the C source files by searching in each VPATH element.
C_SRCS  := $(foreach dir,$(VPATH),$(wildcard $(dir)/*.c))


# Define the object files
OBJS := $(addprefix $(BUILD_OBJ_DIR)/,$(notdir $(C_SRCS:.c=.o)))

DEPS := $(OBJS:.o=.d)
-include $(DEPS)


.PHONY: obj_compile
obj_compile:
	$(AT)                                      \
	mkdir -p $(BUILD_OBJ_DIR) || exit $$?;     \
	make $(OBJS) || exit $$?;                  \


# Compile the C source files.
# NOTE: this is a pattern rule.
$(BUILD_OBJ_DIR)/%.o: %.c
	$(AT)                                     \
	echo "+ Building $(notdir $<)";           \
	$(CC) $(DEPFLAGS) -MT $@ $(CFLAGS) -o $@ $< || exit $$?;     \

$(BUILD_OBJ_DIR)/$(PROJECT_NAME): $(BUILD_OBJ_DIR)/$(PROJECT_NAME).elf
	$(AT)                                              \
	echo "~ Stripping $@          ";                   \
	$(STRIP_CMD) $< $(STRIP_OPTS) $@  || exit $$?;     \


$(BUILD_OBJ_DIR)/$(PROJECT_NAME).elf: obj_compile
	$(AT)                                      \
	echo "x Linking $@ ";                      \
	$(CC) $(LFLAGS) -o $@ $(OBJS) || exit $$?; \
	echo "Build completed.";                   \


# Default build target if no target is specified at command line
.PHONY: default
default: all

.PHONY: all
all: $(BUILD_OBJ_DIR)/$(PROJECT_NAME)
	$(AT) \
	echo "Done.\n" ; \

.PHONY: clean
clean:
	$(AT)                                      \
	echo "Deleting build artifacts...";        \
	rm -rf $(BUILD_OBJ_DIR) || exit $$?;       \

