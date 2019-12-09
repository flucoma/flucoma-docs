cmake_minimum_required(VERSION 3.11)

include(${CMAKE_CURRENT_SOURCE_DIR}/../../../script/dump-pretarget.cmake)

# set(CMAKE_CXX_STANDARD 11)
# set(CMAKE_CXX_STANDARD_REQUIRED ON)
add_executable(
	${PROJECT_NAME}
	${PROJECT_NAME}.cpp
)
# target_link_libraries(${PROJECT_NAME} FLUID_DECOMPOSITION)
# target_include_directories(
# 	${PROJECT_NAME}
# 	PRIVATE
# 	"${CMAKE_CURRENT_SOURCE_DIR}/../../include"
# )
#
# target_include_directories(
# 	${PROJECT_NAME}
# 	SYSTEM PRIVATE
# 	"${C74_MAX_INCLUDES}"
# 	"${C74_MSP_INCLUDES}"
# 	"${C74_JIT_INCLUDES}"
# )

include(${CMAKE_CURRENT_SOURCE_DIR}/../../../script/dump-posttarget.cmake)
