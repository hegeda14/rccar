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
include CMakeFiles/AvoidObjects.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/AvoidObjects.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/AvoidObjects.dir/flags.make

CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o: CMakeFiles/AvoidObjects.dir/flags.make
CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o: AvoidObjects.cpp
	$(CMAKE_COMMAND) -E cmake_progress_report /home/pi/opencv_workspace/TrafficConeDetection/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o -c /home/pi/opencv_workspace/TrafficConeDetection/AvoidObjects.cpp

CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/pi/opencv_workspace/TrafficConeDetection/AvoidObjects.cpp > CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.i

CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/pi/opencv_workspace/TrafficConeDetection/AvoidObjects.cpp -o CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.s

CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o.requires:
.PHONY : CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o.requires

CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o.provides: CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o.requires
	$(MAKE) -f CMakeFiles/AvoidObjects.dir/build.make CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o.provides.build
.PHONY : CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o.provides

CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o.provides.build: CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o

# Object files for target AvoidObjects
AvoidObjects_OBJECTS = \
"CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o"

# External object files for target AvoidObjects
AvoidObjects_EXTERNAL_OBJECTS =

AvoidObjects: CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o
AvoidObjects: CMakeFiles/AvoidObjects.dir/build.make
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_videostab.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_videoio.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_video.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_superres.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_stitching.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_shape.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_photo.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_objdetect.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_ml.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_imgproc.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_imgcodecs.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_highgui.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_flann.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_features2d.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_core.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_calib3d.so.3.1.0
AvoidObjects: libpigpio.a
AvoidObjects: libcommand.a
AvoidObjects: /opt/vc/lib/libmmal_core.so
AvoidObjects: /opt/vc/lib/libmmal_util.so
AvoidObjects: /opt/vc/lib/libmmal.so
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_features2d.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_ml.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_highgui.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_videoio.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_imgcodecs.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_flann.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_video.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_imgproc.so.3.1.0
AvoidObjects: /home/pi/opencv_workspace/opencv/build/lib/libopencv_core.so.3.1.0
AvoidObjects: CMakeFiles/AvoidObjects.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX executable AvoidObjects"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/AvoidObjects.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/AvoidObjects.dir/build: AvoidObjects
.PHONY : CMakeFiles/AvoidObjects.dir/build

CMakeFiles/AvoidObjects.dir/requires: CMakeFiles/AvoidObjects.dir/AvoidObjects.cpp.o.requires
.PHONY : CMakeFiles/AvoidObjects.dir/requires

CMakeFiles/AvoidObjects.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/AvoidObjects.dir/cmake_clean.cmake
.PHONY : CMakeFiles/AvoidObjects.dir/clean

CMakeFiles/AvoidObjects.dir/depend:
	cd /home/pi/opencv_workspace/TrafficConeDetection && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/pi/opencv_workspace/TrafficConeDetection /home/pi/opencv_workspace/TrafficConeDetection /home/pi/opencv_workspace/TrafficConeDetection /home/pi/opencv_workspace/TrafficConeDetection /home/pi/opencv_workspace/TrafficConeDetection/CMakeFiles/AvoidObjects.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/AvoidObjects.dir/depend

