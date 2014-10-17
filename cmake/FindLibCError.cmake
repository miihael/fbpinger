# - Try to find libcerror
# Once done, this will define
#
#  cerror_FOUND - system has cerror
#  cerror_INCLUDE_DIRS - the cerror include directories
#  cerror_LIBRARIES - link these to use cerror

include(LibFindMacros)

if(NOT CERROR_EXECUTABLE)
        message(STATUS "Looking for gen-cerror")
	find_program(CERROR_EXECUTABLE gen-cerror)
	if(CERROR_EXECUTABLE)
		set(CERROR_FOUND TRUE)
	endif(CERROR_EXECUTABLE)
else(NOT CERROR_EXECUTABLE)
	set(CERROR_FOUND TRUE)
endif(NOT CERROR_EXECUTABLE)

# Use pkg-config to get hints about paths
libfind_pkg_check_modules(cerror_PKGCONF libcerror)

# Include dir
find_path(cerror_INCLUDE_DIR
  NAMES cerror.h
  PATHS ${cerror_PKGCONF_INCLUDE_DIRS}
)

# Finally the library itself
find_library(cerror_LIBRARY
  NAMES ${cerror_PKGCONF_LIBRARIES}
  PATHS ${cerror_PKGCONF_LIBRARY_DIRS}
)

# Set the include dir variables and the libraries and let libfind_process do the rest.
# NOTE: Singular variables for this library, plural for libraries this this lib depends on.
set(cerror_PROCESS_INCLUDES cerror_INCLUDE_DIR)
set(cerror_PROCESS_LIBS cerror_LIBRARY)
libfind_process(cerror)

macro(ADD_CERROR_DESCS SRC_FILES INCLUDE_DIR OUT_FILES)
	set(NEW_SOURCE_FILES)
	foreach(CURRENT_FILE ${SRC_FILES})
		get_filename_component(SRCPATH "${CURRENT_FILE}" PATH)
		get_filename_component(SRCBASE "${CURRENT_FILE}" NAME_WE)
		set(OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${SRCPATH}")
		set(OUT "${CMAKE_CURRENT_BINARY_DIR}/${SRCPATH}/${SRCBASE}_error.c")
		set(OUT_HEADER "${CMAKE_CURRENT_BINARY_DIR}/${SRCPATH}/${SRCBASE}_error.h")
		set(INFILE "${CMAKE_CURRENT_SOURCE_DIR}/${CURRENT_FILE}")
		add_custom_command(
			OUTPUT ${OUT} ${OUT_HEADER}
			COMMAND gen-cerror
			-s "${OUT_DIR}"
				-i ${INCLUDE_DIR}
				${INFILE}
			DEPENDS ${CURRENT_FILE}
			COMMENT "Generating cerror for ${INFILE}"
			)
		set(MY_FLAGS "")
		set(MY_FLAGS "${MY_FLAGS} -Wno-unused-variable")

		set_source_files_properties(
			"${CMAKE_CURRENT_BINARY_DIR}/${SRCPATH}/${SRCBASE}_error.c"
			PROPERTIES COMPILE_FLAGS "${MY_FLAGS}"
			)
		list(APPEND NEW_SOURCE_FILES ${OUT})
		list(APPEND NEW_SOURCE_FILES ${OUT_HEADER})
	endforeach(CURRENT_FILE)
	set(${OUT_FILES} ${NEW_SOURCE_FILES})
endmacro(ADD_CERROR_DESCS)
