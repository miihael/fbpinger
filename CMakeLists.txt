cmake_minimum_required(VERSION 2.6)
project(fbpinger C)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

if(NOT CMAKE_BUILD_TYPE)
	message(STATUS "No build type selected, defaulting to RelWithDebInfo")
	set(CMAKE_BUILD_TYPE "RelWithDebInfo")
endif(NOT CMAKE_BUILD_TYPE)

set(CMAKE_C_FLAGS "-Wall -W -Werror -fno-strict-aliasing")

include(CheckIncludeFiles)
include(CheckLibraryExists)
include(FindPkgConfig)

find_package(LibEV REQUIRED)
find_package(LibEVfibers REQUIRED)
find_package(LibCError REQUIRED)
find_package(GenGetOpt REQUIRED)

#execute_process(COMMAND sh -c "head -1 debian/changelog | grep -o -E '\\([^)]+' | cut -b2-"
#	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
#	OUTPUT_VARIABLE DEB_VERSION
#	OUTPUT_STRIP_TRAILING_WHITESPACE
#)

#string(REGEX MATCHALL "[^.]+" DEB_VERSION_LIST "${DEB_VERSION}")
#list(GET DEB_VERSION_LIST 0 VERSION_MAJOR)
#list(GET DEB_VERSION_LIST 1 VERSION_MINOR)
#list(GET DEB_VERSION_LIST 2 VERSION_PATCH)
#set(VERSION_STRING ${DEB_VERSION})
set(VERSION_STRING "0.0.1")

#configure_file(${CMAKE_CURRENT_SOURCE_DIR}/include/arachnid_private/config.h.in
#	${CMAKE_CURRENT_BINARY_DIR}/include/arachnid_private/config.h
#	)

aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/src MY_SOURCES)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include
	${CMAKE_CURRENT_BINARY_DIR}/include
    ${cerror_INCLUDE_DIRS}
    )

#message( STATUS "hiredis:" ${hiredis_INCLUDE_DIRS} )

add_executable(fbpinger ${MY_SOURCES})
target_link_libraries(fbpinger
    ${LIBEVFIBERS_LDFLAGS}
	${LIBEV_LDFLAGS}
    )

#subdirs(lib)

#file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/env)
#install(PROGRAMS service/run DESTINATION /etc/arachnid)
#install(PROGRAMS service/log/run DESTINATION /etc/arachnid/log)
#install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/env DESTINATION /etc/arachnid)
#install(TARGETS arachnid RUNTIME DESTINATION /usr/bin)
