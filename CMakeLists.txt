cmake_minimum_required(VERSION 3.26)

project(TaigiTelex LANGUAGES Swift)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

set(ARCH "native" CACHE STRING "Architecture to build")

set(VALID_ARCH native x86_64 arm64)

if(NOT ARCH IN_LIST VALID_ARCH)
    message(FATAL_ERROR "Invalid ARCH")
endif()

if(NOT ARCH STREQUAL "native")
    add_compile_options(-target "${ARCH}-apple-macos11")
endif()

add_executable(TaigiTelex
    MACOSX_BUNDLE
    src/server.swift
    src/controller.swift
    src/TelexTypes.swift
    src/TelexRules.swift
    src/TelexEngine.swift
)

set(APP_PATH "${CMAKE_CURRENT_BINARY_DIR}/TaigiTelex.app/Contents")

add_custom_command(TARGET TaigiTelex POST_BUILD
    COMMAND mkdir -p "${APP_PATH}/Resources"
    COMMAND cp dmg/TW-input-menu.tiff "${APP_PATH}/Resources"
    COMMAND cp dmg/TW-preference.tiff "${APP_PATH}/Resources"
    COMMAND cp dmg/taigi-telex.icns "${APP_PATH}/Resources"
    COMMAND cp -r dmg/en.lproj "${APP_PATH}/Resources"
    COMMAND rm -f "${APP_PATH}/MacOS/TaigiTelex.d"
    COMMAND "BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}" dmgbuild -s dmg/config.py TaigiTelex "${CMAKE_CURRENT_BINARY_DIR}/TaigiTelex.dmg"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

install(TARGETS TaigiTelex
    BUNDLE DESTINATION "$ENV{HOME}/Library/Input Methods"
)
