set(LLVM_EXPORTED_SYMBOL_FILE ${CMAKE_CURRENT_SOURCE_DIR}/objwriter.exports)

set(LLVM_LINK_COMPONENTS
  AllTargetsDescs
  AllTargetsInfos
  MC
  Support
  )

if (MSVC AND (LLVM_USE_CRT_RELEASE STREQUAL "MT"))
  # Force uCRT to be dynamically linked for Release build
  set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /NODEFAULTLIB:libucrt.lib /DEFAULTLIB:ucrt.lib")
endif()

message(STATUS "ObjWriter configuring with (${CMAKE_BUILD_TYPE}) build type and (${LLVM_DEFAULT_TARGET_TRIPLE}) default target triple")

add_llvm_library(objwriter SHARED
  objwriter.cpp
  debugInfo/codeView/codeViewTypeBuilder.cpp
  debugInfo/codeView/codeViewTypeBuilder.h
  debugInfo/dwarf/dwarfTypeBuilder.cpp
  debugInfo/dwarf/dwarfTypeBuilder.h
  debugInfo/dwarf/dwarfGen.cpp
  debugInfo/dwarf/dwarfGen.h
  debugInfo/dwarf/dwarfAbbrev.cpp
  debugInfo/dwarf/dwarfAbbrev.h
  debugInfo/typeBuilder.h
  objwriter.h # Visual Studio generator doesn't include necessary header files into the project automatically
)
