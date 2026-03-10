cmake_minimum_required(VERSION 3.10.2)

project(calculator_native VERSION 0.0.1 LANGUAGES CXX)

# The path to calculator.cpp relative to this CMakeLists.txt
# From my_app/android/app/src/main/cpp/ to my_app/src/calculator.cpp
# 1: main, 2: src, 3: app, 4: android, 5: my_app
add_library(calculator_native SHARED
  ../../../../../src/calculator.cpp
)

set_target_properties(calculator_native PROPERTIES
  OUTPUT_NAME "calculator_native"
)
