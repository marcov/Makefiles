#################################################################################
#                   Very basic Makefile with dependencies                       #
#                         (C) Marco Vedovati, 2016                              #
#################################################################################

# For help and usage, run "make help"

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
ifndef VPATH
  $(info Attention: no VPATH variable defined specifying all the locations of the source code. Using "." as the only default location)
  VPATH := .
endif

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

# Include single files from the files lis as well.
C_SRCS += $(C_SRC_FILESLIST)

# We need to include the directories of single files to VPATH to make pattern rules work...
VPATH += $(dir $(C_SRC_FILESLIST))

# Define the object files
OBJS := $(addprefix $(BUILD_OBJ_DIR)/,$(notdir $(C_SRCS:.c=.o)))

DEPS := $(OBJS:.o=.d)
-include $(DEPS)

#################################################################################
#
# Rules section
#

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

.PHONY: help
help:
	$(AT) \
	echo "\n   Makefile with dependencies \n \
	\n \
	TL;DR: For a typical usage, clone the git repo containing this Makefile into your main project directory. \n \
	Then, create a local Makefile with the following content: \n \
	\n \
	##### --- Cut from here --- #### \n \
	PROJECT_NAME := my_cool_project_name  \n \
	\n \
	# Build all files inside the following directories list: \n \
	VPATH := dir1 dir2 dir3  \n \
	\n \
	C_SRC_FILESLIST := folder1/single_file_to_build.c folder2/another_single_file_to_build.c \n \
	\n \
	-include Makefiles/Makefile_w_deps.mk \n \
	##### --- Cut till here --- #### \n \
	\n \
	~~~~~~~\n \
	This is the list of make variables you should define or could override: \n \
	\n \
	- VPATH: this is the list of directories containing source code files. NOTE: All files inside these directories will be built! \n \
	  To specify single files, use the variable C_SRC_FILESLIST. \n \
	  These directories are used as well as 'include' directories for your compiler. \n \
	\n \
	- C_SRC_FILESLIST: this is a list of single files that should be built. \n \
	  NOTE: If you want to build all files in a directory, use 'VPATH' instead." \

