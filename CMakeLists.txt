cmake_minimum_required(VERSION 3.11)

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

add_custom_target(MAKE_MAX_REF ALL
	COMMAND ${PYTHON_3} "${CMAKE_CURRENT_SOURCE_DIR}/script/MakeMaxRef.py" "${CMAKE_BINARY_DIR}/json" "${CMAKE_CURRENT_SOURCE_DIR}/doc" "${CMAKE_BINARY_DIR}/maxref" "${CMAKE_CURRENT_SOURCE_DIR}/script/templates"
	COMMENT "Generating Max XML ref"
	VERBATIM
)

add_custom_target (GENERATE_HTML ALL
  DEPENDS MAKE_MAX_REF
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  COMMAND ./generate_html.sh
  COMMENT "Transforming XML to HTML for PD and CLI"
  VERBATIM
)

# Make sure to build targets from fluid_decomposition
# add_subdirectory(${FLUID_ABS_PATH} ${FLUID_ABS_PATH}/build)
MACRO(SUBDIRLIST result curdir)
  FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
  SET(dirlist "")
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
        LIST(APPEND dirlist ${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})
ENDMACRO()

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
