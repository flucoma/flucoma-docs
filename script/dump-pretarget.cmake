# Copyright (c) 2016, Cycling '74
# Usage of this file and its contents is governed by the MIT License

string(REGEX REPLACE "(.*)/" "" THIS_FOLDER_NAME "${CMAKE_CURRENT_SOURCE_DIR}")
project(${THIS_FOLDER_NAME})
