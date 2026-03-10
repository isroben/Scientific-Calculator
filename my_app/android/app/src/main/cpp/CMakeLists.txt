cmake_minimum_required(VERSION 3.10.2)

project(calculator_native VERSION 0.0.1 LANGUAGES CXX)

add_library(calculator_native SHARED
  ../../../../src/calculator.cpp
)

set_target_properties(calculator_native PROPERTIES
  PUBLIC_HEADER ../../../../src/calculator.cpp
  OUTPUT_NAME "calculator_native"
)
