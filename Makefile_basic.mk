#################################################################################
#                            Very basic Makefile                                #
#                         (C) Marco Vedovati, 2016                              #
#################################################################################

PROJECT_NAME = $(shell basename ${PWD})

#################################################################################
# Note: VPATH is a standard Makefile variable,
# specifying a list of directories that make should search.
VPATH = .


CFLAGS_WARN   = -Wall -Werror -Wextra -Wundef 
CFLAGS        = $(CFLAGS_WARN) -c -g -ggdb 
AT            = @
BUILD_OBJ_DIR = build


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
	$(CC) $(CFLAGS) -o $@ $< || exit $$?;     \


$(BUILD_OBJ_DIR)/$(PROJECT_NAME).bin: obj_compile
	$(AT)                                      \
	echo "x Linking $@ ";                      \
	$(CC) $(LFLAGS) -o $@ $(OBJS) || exit $$?; \
	echo "Build completed.";                   \


# Default build target if no target is specified at command line
.PHONY: default
default: all

.PHONY: all
all: $(BUILD_OBJ_DIR)/$(PROJECT_NAME).bin


.PHONY: clean
clean:
	$(AT)                                      \
	echo "Deleting build artifacts...";        \
	rm -rf $(BUILD_OBJ_DIR) || exit $$?;       \

