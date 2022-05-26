# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

cmake_minimum_required(VERSION 3.18)

include(FLuidClientStub)

function(add_doc_gen name source)
  
  add_executable(${name} ${source})
  
  target_link_libraries(${name} PRIVATE
      FLUID_DECOMPOSITION FLUID_DUMP
  )

  target_include_directories (
  	${name}
  	PRIVATE
  	"${CMAKE_CURRENT_SOURCE_DIR}/../../../include"
  	"${CMAKE_CURRENT_SOURCE_DIR}/../../../thirdparty"
  )

  if(APPLE)
    set_target_properties(${name} PROPERTIES
      XCODE_GENERATE_SCHEME ON
    )
    #If we target 10.7 (actually < 10.9), we have to manually include this:
    target_compile_options(${name} PRIVATE -stdlib=libc++)
  endif()

  if(MSVC)
    target_compile_options(${name} PRIVATE /W3)
  else()
    target_compile_options(${name} PRIVATE -Wall -Wextra -Wpedantic -Wno-return-type -Wno-c++11-narrowing)
  endif()

  get_property(HEADERS TARGET FLUID_DECOMPOSITION PROPERTY INTERFACE_SOURCES)
  source_group(TREE "${flucoma-core_SOURCE_DIR}/include" FILES ${HEADERS})

endfunction()

function(make_external_name client header var)  
  set(${var} ${client} PARENT_SCOPE)
endfunction()

function(generate_doc_exe) 
  # # Define the supported set of keywords
  set(noValues "")
  set(singleValues FILENAME EXTERNALS_OUT FILE_OUT)
  set(multiValues CLIENTS HEADERS CLASSES)
  # # Process the arguments passed in
  include(CMakeParseArguments)
  cmake_parse_arguments(ARG
  "${noValues}"
  "${singleValues}"
  "${multiValues}"
  ${ARGN})  
  
  if(ARG_FILENAME)
    set(external_name ${ARG_FILENAME})
  else()
    list(GET ARG_CLIENTS 0 external_name)
  endif()
  
  set(ENTRY_POINT "int main(int argc, char *argv[])")
  set(WRAPPER_TEMPLATE [=[ParameterDump<${class}>::dump("${external}", argv[1]);]=])
  set(CCE_WRAPPER "#include \"FluidParameterDump.hpp\"")
  
  generate_source(${ARGN} EXTERNALS_OUT external FILE_OUT outfile)
  
  message(STATUS "Generating: ${external_name}")
  add_doc_gen(${external_name} ${outfile})
  
endfunction()
