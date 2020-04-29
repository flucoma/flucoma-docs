# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

cmake_minimum_required(VERSION 3.11)

if(APPLE)
  set(CMAKE_OSX_DEPLOYMENT_TARGET 10.8)
endif()

project (flucoma-docs LANGUAGES CXX)

set(FLUID_PATH "" CACHE PATH "The top level of the flucoma-core repo. Will clone from repo if blank")
set(FLUID_M_PATH ~/fluid_manipulation CACHE PATH "The top level of the fluid_manipulation repo")
include(FetchContent)

set(FETCHCONTENT_QUIET FALSE)

FetchContent_Declare(
  flucoma-core
  GIT_REPOSITORY https://bitbucket.org/flucoma/fluid_decomposition.git
  GIT_PROGRESS TRUE
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

set(FLUID_JSON_DOC "${CMAKE_BINARY_DIR}/json")
set(FLUID_YAML_DOC "${CMAKE_CURRENT_SOURCE_DIR}/doc")
set(FLIUD_JINJA_TEMPLATES "${CMAKE_CURRENT_SOURCE_DIR}/script/templates")

macro(add_ref_target platform comment)  
  string(TOUPPER ${platform} platform_uc)
  string(TOLOWER ${platform} platform_lc)
  get_directory_property(hasParent PARENT_DIRECTORY)
  if(hasParent)
    set(FLUID_${platform_uc}_REF_TARGET MAKE_${platform_uc}_REF PARENT_SCOPE)
    set(FLUID_${platform_uc}_REF_PATH "${CMAKE_BINARY_DIR}/${platform_lc}_ref" PARENT_SCOPE)
  endif()
  add_custom_target(MAKE_${platform_uc}_REF
    COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/${platform_lc}_ref"
  	COMMAND ${PYTHON_3} "${CMAKE_CURRENT_SOURCE_DIR}/script/MakeRef.py" "${platform_lc}" ${FLUID_JSON_DOC} ${FLUID_YAML_DOC} "${CMAKE_BINARY_DIR}/${platform_lc}_ref" ${FLIUD_JINJA_TEMPLATES}
  	COMMENT ${comment}
  	VERBATIM
  )
endmacro()

add_ref_target(max "Making Max ref")
add_ref_target(pd "Making PD ref")
add_ref_target(cli "Making CLI ref")

# Make sure to build targets from flucoma-core
macro(subdirlist result curdir)
  file(GLOB children RELATIVE ${curdir} ${curdir}/*)
  set(dirlist "")
  foreach(child ${children})
    if(IS_DIRECTORY ${curdir}/${child})
        list(APPEND dirlist ${child})
    endif()
  endforeach()
  set(${result} ${dirlist})
endmacro()

# Generate a project for every folder in the "src/clients" folder
subdirlist(PROJECT_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/src/clients)
foreach (project_dir ${PROJECT_DIRS})
	if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/clients/${project_dir}/CMakeLists.txt")
		message("Generating: ${project_dir}")
		add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/src/clients/${project_dir})
	endif ()
endforeach ()
