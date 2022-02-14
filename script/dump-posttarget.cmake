# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).


target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_14)

set_target_properties(${PROJECT_NAME} PROPERTIES
  CXX_STANDARD_REQUIRED ON
  CXX_STANDARD 14
  CXX_EXTENSIONS OFF
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    FLUID_DECOMPOSITION FLUID_DUMP
)

target_include_directories (
	${PROJECT_NAME}
	PRIVATE
	"${CMAKE_CURRENT_SOURCE_DIR}/../../../include"
	"${CMAKE_CURRENT_SOURCE_DIR}/../../../thirdparty"
)

if(APPLE)
  set_target_properties(${PROJECT_NAME} PROPERTIES
    XCODE_GENERATE_SCHEME ON
  )
  #If we target 10.7 (actually < 10.9), we have to manually include this:
  target_compile_options(${PROJECT_NAME} PRIVATE -stdlib=libc++)
endif()


if(MSVC)
  target_compile_options(${PROJECT_NAME}PRIVATE /W3)
else()
  target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Wpedantic -Wno-return-type -Wno-c++11-narrowing)
endif()

get_property(HEADERS TARGET FLUID_DECOMPOSITION PROPERTY INTERFACE_SOURCES)
source_group(TREE "${flucoma-core_SOURCE_DIR}/include" FILES ${HEADERS})

if ("${PROJECT_NAME}" MATCHES ".*_tilde")
	string(REGEX REPLACE "_tilde" "~" EXTERN_OUTPUT_NAME "${PROJECT_NAME}")
else ()
    set(EXTERN_OUTPUT_NAME "${PROJECT_NAME}")
endif ()
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "${EXTERN_OUTPUT_NAME}")

# add_custom_command(
# 	TARGET ${PROJECT_NAME}
# 	POST_BUILD
# 	COMMAND $<TARGET_FILE:${PROJECT_NAME}> ARGS "${CMAKE_BINARY_DIR}/json/"
# 	COMMENT "Generating JSON for ${PROJECT_NAME}"
# )



# add_dependencies(
# 	MAKE_MAX_REF "${CMAKE_BINARY_DIR}/json/${PROJECT_NAME}.json"
# )
