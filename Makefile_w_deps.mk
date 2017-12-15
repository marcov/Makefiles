#################################################################################
#                   Very basic Makefile with dependencies                       #
#                         (C) Marco Vedovati, 2016                              #
#################################################################################

# For help and usage, run "make help"

define BASIC_MAKEFILE_TXT

    Makefile with dependencies

TL;DR: For a typical usage, clone the git repo containing this Makefile into
your main project directory. Then, create a local Makefile using the following
as with the following as a base file and editing as needed:

##### --- Cut from here --- ####
PROJECT_NAME := my_cool_project_name

# Specify a cross-compiler prefix if needed
CROSS_PREFIX := archfoo-libbar-

# Build all files inside the following directories list:
VPATH := dir1 dir2 dir3

C_SRC_FILESLIST := folder1/single_file_to_build.c folder2/another_single_file_to_build.c

# List of paths of extra directories to include
INCLUDE_PATHS_LIST := /path1/foo/bar /path2/tom/boy

# Extra CFLAGS to use when compiling
USER_CFLAGS := -DENABLE_SECRET_FX

# Extra LFLAGS to use when linking
USER_LFLAGS := -T linkerfile.ld

-include Makefiles/Makefile_w_deps.mk
##### --- Cut till here --- ####

~~~~~~~

Some more information:

- VPATH: this is the list of directories containing source code files. NOTE: All files inside these directories will be built!
To specify single files, use the variable C_SRC_FILESLIST.
These directories are used as well as 'include' directories for your compiler.

- C_SRC_FILESLIST: this is a list of single files that should be built.
NOTE: If you want to build all files in a directory, use 'VPATH' instead.

endef

PROJECT_NAME ?= $(shell basename ${PWD})

DEBUG_LEVEL  ?= Debug

# Specify a cross-compiler prefix if needed
CROSS_PREFIX ?=

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

ifeq (, $(shell which $(CC)))
  $(error Compiler '$(CC)' not found in PATH)
endif


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

CFLAGS += $(USER_CFLAGS)
LFLAGS += $(USER_LFLAGS)

# Including the same paths used for source lookup. Add more as needed...
INCLUDE_PATHS_LIST +=  \
  $(VPATH)

#################################################################################
#

# Auto-generating CC -I list
CFLAGS  += $(foreach dir,$(INCLUDE_PATHS_LIST),-I$(dir) )

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
	echo $(info $(BASIC_MAKEFILE_TXT)) ;      \

