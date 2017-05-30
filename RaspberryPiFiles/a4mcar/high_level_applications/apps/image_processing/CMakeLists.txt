cmake_minimum_required(VERSION 2.8)
project( TrafficConeDetection )
find_package( OpenCV REQUIRED )
find_package( raspicam REQUIRED )
find_package(Threads)
include_directories( ${OpenCV_INCLUDE_DIRS} )

add_executable( image_processing image_processing.cpp )

target_link_libraries( image_processing ${OpenCV_LIBS} )
target_link_libraries( image_processing ${CMAKE_THREAD_LIBS_INIT} )
target_link_libraries( image_processing ${raspicam_LIBS} )
target_link_libraries( image_processing ${raspicam_CV_LIBS} )


