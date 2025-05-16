# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\TaikoGame_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\TaikoGame_autogen.dir\\ParseCache.txt"
  "TaikoGame_autogen"
  )
endif()
