cmake_minimum_required(VERSION 3.18.1)
project(calc_engine)

add_library(calc_engine SHARED
            calc_engine.cpp
            calculator.cpp) # Path from cpp folder to root src

target_link_libraries(calc_engine android log)