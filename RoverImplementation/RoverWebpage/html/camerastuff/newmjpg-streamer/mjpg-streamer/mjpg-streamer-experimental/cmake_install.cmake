# Install script for directory: /var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental/CMakeFiles/CMakeRelink.dir/mjpg_streamer")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/mjpg-streamer" TYPE DIRECTORY FILES "/var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental/www")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental/plugins/input_file/cmake_install.cmake")
  include("/var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental/plugins/input_http/cmake_install.cmake")
  include("/var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental/plugins/input_opencv/cmake_install.cmake")
  include("/var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental/plugins/input_raspicam/cmake_install.cmake")
  include("/var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental/plugins/input_ptp2/cmake_install.cmake")
  include("/var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental/plugins/input_uvc/cmake_install.cmake")
  include("/var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental/plugins/output_file/cmake_install.cmake")
  include("/var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental/plugins/output_http/cmake_install.cmake")
  include("/var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental/plugins/output_rtsp/cmake_install.cmake")
  include("/var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental/plugins/output_udp/cmake_install.cmake")
  include("/var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental/plugins/output_viewer/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/var/www/html/camerastuff/newmjpg-streamer/mjpg-streamer/mjpg-streamer-experimental/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
