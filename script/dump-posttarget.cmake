# Bits of this Copyright (c) 2016, Cycling '74
# Usage of this file and its contents is governed by the MIT License


target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_14)
add_dependencies (${PROJECT_NAME} FLUID_DECOMPOSITION)
target_link_libraries(${PROJECT_NAME}
PUBLIC FLUID_DECOMPOSITION  FLUID_DUMP
PRIVATE FFTLIB
)

target_include_directories (
	${PROJECT_NAME}
	SYSTEM PRIVATE
	"${CMAKE_CURRENT_SOURCE_DIR}/../../../include"
	"${CMAKE_CURRENT_SOURCE_DIR}/../../../thirdparty"
)

if(MSVC)
  target_compile_options(${PROJECT_NAME}PRIVATE /W4 /WX)
else()
  target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Wpedantic -Wreturn-type -Wconversion)
endif()


get_property(HEADERS TARGET FLUID_DECOMPOSITION PROPERTY INTERFACE_SOURCES)
source_group(TREE "${FLUID_PATH}/include" FILES ${HEADERS})

if ("${PROJECT_NAME}" MATCHES ".*_tilde")
	string(REGEX REPLACE "_tilde" "~" EXTERN_OUTPUT_NAME "${PROJECT_NAME}")
else ()
    set(EXTERN_OUTPUT_NAME "${PROJECT_NAME}")
endif ()
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "${EXTERN_OUTPUT_NAME}")

add_custom_command(
	TARGET ${PROJECT_NAME}
	POST_BUILD
	COMMAND $<TARGET_FILE:${PROJECT_NAME}> ARGS "${CMAKE_SOURCE_DIR}/json/"
	COMMENT "Generating JSON for ${PROJECT_NAME}"
)


### Output ###


### Post Build ###
#if (WIN32)
#	add_custom_command(
#		TARGET ${PROJECT_NAME}
#		POST_BUILD
#		COMMAND rm "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${EXTERN_OUTPUT_NAME}.ilk"
#		COMMENT "ilk file cleanup"
#	)
#endif ()
