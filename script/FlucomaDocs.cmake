# Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
# Copyright 2017-2019 University of Huddersfield.
# Licensed under the BSD-3 License.
# See license.md file in the project root for full license information.
# This project has received funding from the European Research Council (ERC)
# under the European Union’s Horizon 2020 research and innovation programme
# (grant agreement No 725899).

cmake_minimum_required(VERSION 3.18)

macro(add_ref_target platform comment)  
  string(TOUPPER ${platform} platform_uc)
  string(TOLOWER ${platform} platform_lc)
    
  set(FLUID_${platform_uc}_REF_TARGET MAKE_${platform_uc}_REF)
  set(FLUID_${platform_uc}_REF_PATH "${CMAKE_BINARY_DIR}/${platform_lc}_ref")
  
  get_property(DOC_ROOT GLOBAL PROPERTY FLUID_DOCS_ROOT)
  
  set(FLUID_GENERATED_DOC "${CMAKE_BINARY_DIR}/json")
  set(FLUID_HUMAN_DOC "${DOC_ROOT}/doc")
  set(FLIUD_JINJA_TEMPLATES "${DOC_ROOT}/flucoma/doc/templates")
  
  add_custom_target(MAKE_${platform_uc}_REF
    COMMAND ${CMAKE_COMMAND} -E make_directory "${${platform_uc}_DOC_OUT}"
  	COMMAND ${PYTHON_3} "-mflucoma.MakeRef" "${platform_lc}" ${FLUID_GENERATED_DOC} ${FLUID_HUMAN_DOC} "${${platform_uc}_DOC_OUT}" ${FLIUD_JINJA_TEMPLATES}
    WORKING_DIRECTORY ${DOC_ROOT}
  	COMMENT ${comment}
    # DEPENDS ${json_files}
  	VERBATIM
  )
  add_dependencies(MAKE_${platform_uc}_REF DumpParams)
endmacro()
