include(GNUInstallDirs)
include(LLVMDistributionSupport)

macro(add_lld_library name)
  cmake_parse_arguments(ARG
    "SHARED"
    ""
    ""
    ${ARGN})
  if(ARG_SHARED)
    set(ARG_ENABLE_SHARED SHARED)
  endif()
  llvm_add_library(${name} ${ARG_ENABLE_SHARED} ${ARG_UNPARSED_ARGUMENTS})
  set_target_properties(${name} PROPERTIES FOLDER "lld libraries")

  if (NOT LLVM_INSTALL_TOOLCHAIN_ONLY)
    get_target_export_arg(${name} LLD export_to_lldtargets)
    install(TARGETS ${name}
      COMPONENT ${name}
      ${export_to_lldtargets}
      LIBRARY DESTINATION lib${LLVM_LIBDIR_SUFFIX}
      ARCHIVE DESTINATION lib${LLVM_LIBDIR_SUFFIX}
      RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")

    if (${ARG_SHARED} AND NOT CMAKE_CONFIGURATION_TYPES)
      add_llvm_install_targets(install-${name}
        DEPENDS ${name}
        COMPONENT ${name})
    endif()
    set_property(GLOBAL APPEND PROPERTY LLD_EXPORTS ${name})
  endif()
endmacro(add_lld_library)

macro(add_lld_executable name)
  add_llvm_executable(${name} ${ARGN})
  set_target_properties(${name} PROPERTIES FOLDER "lld executables")
endmacro(add_lld_executable)

macro(add_lld_tool name)
  if (NOT LLD_BUILD_TOOLS)
    set(EXCLUDE_FROM_ALL ON)
  endif()

  add_lld_executable(${name} ${ARGN})

  if (LLD_BUILD_TOOLS)
    get_target_export_arg(${name} LLD export_to_lldtargets)
    install(TARGETS ${name}
      ${export_to_lldtargets}
      RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
      COMPONENT ${name})

    if(NOT CMAKE_CONFIGURATION_TYPES)
      add_llvm_install_targets(install-${name}
        DEPENDS ${name}
        COMPONENT ${name})
    endif()

    if(APPLE)
      if(LLVM_EXTERNALIZE_DEBUGINFO_INSTALL)
        if(LLVM_EXTERNALIZE_DEBUGINFO_EXTENSION)
          set(file_ext ${LLVM_EXTERNALIZE_DEBUGINFO_EXTENSION})
        elseif(LLVM_EXTERNALIZE_DEBUGINFO_FLATTEN)
          set(file_ext dwarf)
        else()
          set(file_ext dSYM)
        endif()
        set(output_name "$<TARGET_FILE_NAME:${name}>.${file_ext}")
        if(LLVM_EXTERNALIZE_DEBUGINFO_OUTPUT_DIR)
          set(output_path "${LLVM_EXTERNALIZE_DEBUGINFO_OUTPUT_DIR}/${output_name}")
        else()
          set(output_path "${output_name}")
        endif()
        get_filename_component(debuginfo_absolute_path ${output_path} REALPATH BASE_DIR $<TARGET_FILE_DIR:${name}>)
        install(FILES ${debuginfo_absolute_path} DESTINATION bin OPTIONAL COMPONENT ${name})
      endif()
    elseif(WIN32)
      if(LLVM_EXTERNALIZE_DEBUGINFO_INSTALL)
        install(FILES $<TARGET_PDB_FILE:${name}> DESTINATION bin OPTIONAL COMPONENT ${name})
      endif()
    else()
      if(LLVM_EXTERNALIZE_DEBUGINFO_INSTALL)
        if(LLVM_EXTERNALIZE_DEBUGINFO_EXTENSION)
          set(file_ext ${LLVM_EXTERNALIZE_DEBUGINFO_EXTENSION})
        else()
          set(file_ext debug)
        endif()

        set(output_name "$<TARGET_FILE_NAME:${name}>.${file_ext}")

        if(LLVM_EXTERNALIZE_DEBUGINFO_OUTPUT_DIR)
          set(output_path "${LLVM_EXTERNALIZE_DEBUGINFO_OUTPUT_DIR}/${output_name}")
          # If an output dir is specified, it must be manually mkdir'd on Linux,
          # as that directory needs to exist before we can pipe to a file in it.
          add_custom_command(TARGET ${name} POST_BUILD
            WORKING_DIRECTORY ${LLVM_RUNTIME_OUTPUT_INTDIR}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${LLVM_EXTERNALIZE_DEBUGINFO_OUTPUT_DIR}
            )
        else()
          set(output_path "${output_name}")
        endif()

        get_filename_component(debuginfo_absolute_path ${output_path} REALPATH BASE_DIR $<TARGET_FILE_DIR:${name}>)
        install(FILES ${debuginfo_absolute_path} DESTINATION bin OPTIONAL COMPONENT ${name})
      endif()
    endif()

    set_property(GLOBAL APPEND PROPERTY LLD_EXPORTS ${name})
  endif()
endmacro()

macro(add_lld_symlink name dest)
  llvm_add_tool_symlink(LLD ${name} ${dest} ALWAYS_GENERATE)
  # Always generate install targets
  llvm_install_symlink(LLD ${name} ${dest} ALWAYS_GENERATE)
endmacro()
