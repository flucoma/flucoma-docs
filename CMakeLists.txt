# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

cmake_minimum_required(VERSION 3.18)

# cmake_policy(SET CMP0074 NEW) 

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

if (APPLE)
  set(CMAKE_XCODE_GENERATE_SCHEME ON)
  set(CMAKE_OSX_DEPLOYMENT_TARGET 10.8)
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/script")
get_directory_property(hasParent PARENT_DIRECTORY)
if(hasParent)
  set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/script 
  PARENT_SCOPE)
endif()

project (flucoma-docs LANGUAGES CXX)

set_property(GLOBAL PROPERTY FLUID_DOCS_ROOT ${CMAKE_CURRENT_SOURCE_DIR})
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(CMAKE_XCODE_GENERATE_TOP_LEVEL_PROJECT_ONLY ON)

set(FLUID_PATH "" CACHE PATH "The top level of the flucoma-core repo. Will clone from repo if blank")

set(RAW_DOC_OUT  "${CMAKE_BINARY_DIR}" CACHE PATH "") 

include(FetchContent)

set(FETCHCONTENT_QUIET FALSE)

FetchContent_Declare(
  flucoma-core
  GIT_REPOSITORY https://github.com/flucoma/flucoma-core.git
  GIT_PROGRESS TRUE
  GIT_TAG origin/main
)

if(FLUID_PATH)
get_filename_component(
  FETCHCONTENT_SOURCE_DIR_FLUCOMA-CORE ${FLUID_PATH} ABSOLUTE
)
endif()

FetchContent_GetProperties(flucoma-core)
if(NOT flucoma-core_POPULATED)
FetchContent_Populate(flucoma-core)
add_subdirectory(${flucoma-core_SOURCE_DIR} ${flucoma-core_BINARY_DIR})
endif()

if (NOT (EXISTS "${CMAKE_BINARY_DIR}/json/"))
	file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/json/")
endif()

add_library(FLUID_DUMP INTERFACE)

target_include_directories(FLUID_DUMP INTERFACE 
"${CMAKE_CURRENT_SOURCE_DIR}/include/"
)

target_sources(FLUID_DUMP INTERFACE
	"${CMAKE_CURRENT_SOURCE_DIR}/include/FluidParameterDump.hpp"
)
source_group("Fluid Paramdump Wrapper" FILES 
  "${CMAKE_CURRENT_SOURCE_DIR}/include/FluidParameterDump.hpp"
)
if(${CMAKE_VERSION} VERSION_LESS "3.12.0")
  find_program(PYTHON_3 python3)
else()
  find_package (Python COMPONENTS Interpreter)
  if(Python_FOUND)
    set(PYTHON_3 ${Python_EXECUTABLE} CACHE PATH "")
  endif()
endif()
    
message(STATUS ${PYTHON_3})
if(NOT PYTHON_3)
  message(FATAL_ERROR "Python 3 not found, won't be doing attempting to generate docs")
endif()

set(FLUID_GENERATED_DOC "${CMAKE_BINARY_DIR}/json")
set(FLUID_HUMAN_DOC "${CMAKE_CURRENT_SOURCE_DIR}/doc")
set(FLIUD_JINJA_TEMPLATES "${CMAKE_CURRENT_SOURCE_DIR}/flucoma/doc/templates")

include(MakeDocSource)

get_core_clients(client_list)

foreach(client ${client_list})  
  get_core_client_header(${client} header)  
  get_core_client_class(${client} class)  
  list(APPEND FLUID_CLIENTS ${client})
  list(APPEND FLUID_HEADERS ${header})
  list(APPEND FLUID_CLASSES ${class})
endforeach()

generate_doc_exe(
  CLIENTS ${FLUID_CLIENTS}
  HEADERS ${FLUID_HEADERS}
  CLASSES ${FLUID_CLASSES}
  FILENAME DumpParams
)

set(JSON_FILES ${FLUID_CLIENTS})
list(TRANSFORM FLUID_CLIENTS APPEND .json)
list(TRANSFORM JSON_FILES PREPEND "${CMAKE_BINARY_DIR}/json/")

add_custom_command(TARGET DumpParams POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E rm -rf "${CMAKE_BINARY_DIR}/json/"
  COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/json/"
  COMMAND $<TARGET_FILE:DumpParams> ARGS "${CMAKE_BINARY_DIR}/json/"
)

include(FlucomaDocs)
add_ref_target(raw "Making raw API JSON")

enable_testing()

execute_process(
  COMMAND ${PYTHON_3} "list_python_tests.py" 
  OUTPUT_VARIABLE FLUCOMA-DOC-PYTHON_TESTS
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_STRIP_TRAILING_WHITESPACE
)

separate_arguments(TEST_LIST UNIX_COMMAND ${FLUCOMA-DOC-PYTHON_TESTS})

foreach(THIS_TEST ${TEST_LIST})
    message(STATUS ${THIS_TEST})
    add_test(
      NAME ${THIS_TEST} 
      COMMAND ${PYTHON_3} "-m" "unittest" "-v" ${THIS_TEST}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endforeach()
