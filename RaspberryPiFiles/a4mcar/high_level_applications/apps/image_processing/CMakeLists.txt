cmake_minimum_required(VERSION 2.8)
project( TrafficConeDetection )
find_package( OpenCV REQUIRED )
find_package( raspicam REQUIRED )
find_package(Threads)
include_directories( ${OpenCV_INCLUDE_DIRS} )
include_directories( /home/pi/opencv_workspace/pigpio)
add_library(pigpio /home/pi/opencv_workspace/pigpio/pigpio.c)
add_library(command /home/pi/opencv_workspace/pigpio/command.c)

add_executable( image_processing image_processing.cpp )

target_link_libraries( image_processing ${OpenCV_LIBS} )
target_link_libraries( image_processing pigpio )
target_link_libraries( image_processing command )
target_link_libraries( image_processing ${CMAKE_THREAD_LIBS_INIT} )
target_link_libraries( image_processing ${raspicam_LIBS} )
target_link_libraries( image_processing ${raspicam_CV_LIBS} )


