# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.0

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/pi/opencv_workspace/TrafficConeDetection

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/pi/opencv_workspace/TrafficConeDetection

# Include any dependencies generated for this target.
include CMakeFiles/command.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/command.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/command.dir/flags.make

CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o: CMakeFiles/command.dir/flags.make
CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o: /home/pi/opencv_workspace/pigpio/command.c
	$(CMAKE_COMMAND) -E cmake_progress_report /home/pi/opencv_workspace/TrafficConeDetection/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building C object CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o"
	/usr/bin/cc  $(C_DEFINES) $(C_FLAGS) -o CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o   -c /home/pi/opencv_workspace/pigpio/command.c

CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.i"
	/usr/bin/cc  $(C_DEFINES) $(C_FLAGS) -E /home/pi/opencv_workspace/pigpio/command.c > CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.i

CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.s"
	/usr/bin/cc  $(C_DEFINES) $(C_FLAGS) -S /home/pi/opencv_workspace/pigpio/command.c -o CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.s

CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o.requires:
.PHONY : CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o.requires

CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o.provides: CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o.requires
	$(MAKE) -f CMakeFiles/command.dir/build.make CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o.provides.build
.PHONY : CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o.provides

CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o.provides.build: CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o

# Object files for target command
command_OBJECTS = \
"CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o"

# External object files for target command
command_EXTERNAL_OBJECTS =

libcommand.a: CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o
libcommand.a: CMakeFiles/command.dir/build.make
libcommand.a: CMakeFiles/command.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking C static library libcommand.a"
	$(CMAKE_COMMAND) -P CMakeFiles/command.dir/cmake_clean_target.cmake
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/command.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/command.dir/build: libcommand.a
.PHONY : CMakeFiles/command.dir/build

CMakeFiles/command.dir/requires: CMakeFiles/command.dir/home/pi/opencv_workspace/pigpio/command.c.o.requires
.PHONY : CMakeFiles/command.dir/requires

CMakeFiles/command.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/command.dir/cmake_clean.cmake
.PHONY : CMakeFiles/command.dir/clean

CMakeFiles/command.dir/depend:
	cd /home/pi/opencv_workspace/TrafficConeDetection && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/pi/opencv_workspace/TrafficConeDetection /home/pi/opencv_workspace/TrafficConeDetection /home/pi/opencv_workspace/TrafficConeDetection /home/pi/opencv_workspace/TrafficConeDetection /home/pi/opencv_workspace/TrafficConeDetection/CMakeFiles/command.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/command.dir/depend
