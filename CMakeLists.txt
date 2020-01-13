cmake_minimum_required(VERSION 3.11)

if(APPLE)
  set(CMAKE_OSX_DEPLOYMENT_TARGET 10.7)
endif()

project (fluid_parameter_dump LANGUAGES CXX)

set(FLUID_PATH "" CACHE PATH "The top level of the fluid_decomposition repo. Will clone from repo if blank")
# set(FLUID_M_PATH "" CACHE PATH "Top level of fluid fluid_manipulation. Will clone from repo if blank" )

include(FetchContent)

set(FETCHCONTENT_QUIET FALSE)

FetchContent_Declare(
  fluid_decomposition
  GIT_REPOSITORY https://bitbucket.org/flucoma/fluid_decomposition.git
  GIT_PROGRESS TRUE
)

if(FLUID_PATH)
get_filename_component(
  FETCHCONTENT_SOURCE_DIR_FLUID_DECOMPOSITION ${FLUID_PATH} ABSOLUTE
)
endif()

FetchContent_GetProperties(fluid_decomposition)
if(NOT fluid_decomposition_POPULATED)
FetchContent_Populate(fluid_decomposition)
add_subdirectory(${fluid_decomposition_SOURCE_DIR} ${fluid_decomposition_BINARY_DIR})
endif()

if (NOT (EXISTS "${CMAKE_BINARY_DIR}/json/"))
	file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/json/")
endif()

if (NOT (EXISTS "${CMAKE_BINARY_DIR}/maxref/"))
	file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/maxref/")
endif()

if (NOT (EXISTS "${CMAKE_BINARY_DIR}/pdhtml/"))
	file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/pdhtml/")
endif()

if (NOT (EXISTS "${CMAKE_BINARY_DIR}/clihtml/"))
	file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/clihtml/")
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

find_program(PYTHON_3 python3)
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
  set(FLUID_${platform_uc}_REF_TARGET MAKE_${platform_uc}_REF)
  set(FLUID_${platform_uc}_REF_PATH "${CMAKE_BINARY_DIR}/${platform_lc}_ref")
  add_custom_target(MAKE_${platform_uc}_REF
    COMMAND ${CMAKE_COMMAND} -E make_directory ${FLUID_${platform_uc}_REF_PATH}
  	COMMAND ${PYTHON_3} "${CMAKE_CURRENT_SOURCE_DIR}/script/MakeRef.py" "${platform_lc}" ${FLUID_JSON_DOC} ${FLUID_YAML_DOC} ${FLUID_${platform_uc}_REF_PATH} ${FLIUD_JINJA_TEMPLATES}
  	COMMENT ${comment}
  	VERBATIM
  )
endmacro()

add_ref_target(max "Making Max ref")
add_ref_target(pd "Making PD ref")
add_ref_target(cli "Making CLI ref")

# Make sure to build targets from fluid_decomposition
# add_subdirectory(${FLUID_ABS_PATH} ${FLUID_ABS_PATH}/build)
macro(SUBDIRLIST result curdir)
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
SUBDIRLIST(PROJECT_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/src/clients)
foreach (project_dir ${PROJECT_DIRS})
	if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/clients/${project_dir}/CMakeLists.txt")
		message("Generating: ${project_dir}")
		add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/src/clients/${project_dir})
	endif ()
endforeach ()

# add_custom_target(ALLJSON)
# add_dependencies(ALLJSON ${PROJECT_DIRS})
