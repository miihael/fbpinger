
SET(LIBEVFIBERS_PATH "" CACHE PATH "Base path for include/ev.h and lib/libev*")
SET(LIBEVFIBERS_INCLUDE_PATH "" CACHE PATH "Include path for ev.h")
SET(LIBEVFIBERS_LIBDIR "" CACHE PATH "Path containing libev")

IF(LIBEVFIBERS_PATH)
	SET(LIBEVFIBERS_INCLUDE_PATH "${LIBEVFIBERS_PATH}/include" CACHE PATH "Include path for evfibers.h" FORCE)
	SET(LIBEVFIBERS_LIBDIR "${LIBEVFIBERS_PATH}/lib" CACHE PATH "Path containing libevfibers" FORCE)
ENDIF(LIBEVFIBERS_PATH)

IF(LIBEVFIBERS_INCLUDE_PATH)
	INCLUDE_DIRECTORIES(${LIBEVFIBERS_INCLUDE_PATH})
ENDIF(LIBEVFIBERS_INCLUDE_PATH)

# Use cached result
IF(NOT LIBEVFIBERS_FOUND)
	UNSET(HAVE_EV_H)
	UNSET(HAVE_LIBEVFIBERS)
	UNSET(HAVE_EV_H CACHE)
	UNSET(HAVE_LIBEVFIBERS CACHE)
	UNSET(LIBEVFIBERS_CFLAGS)
	UNSET(LIBEVFIBERS_LDFLAGS)

	IF(LIBEVFIBERS_INCLUDE_PATH OR LIBEVFIBERS_LIBDIR)
		SET(CMAKE_REQUIRED_INCLUDES ${LIBEVFIBERS_INCLUDE_PATH})
		CHECK_INCLUDE_FILES(evfibers/fiber.h HAVE_EVFIBERS_H)
		IF(HAVE_EVFIBERS_H)
			CHECK_LIBRARY_EXISTS(evfibers fbr_alloc "${LIBEVFIBERS_LIBDIR}" HAVE_LIBEVFIBERS)
			IF(HAVE_LIBEVFIBERS)
				SET(LIBEVFIBERS_LIBRARIES ev CACHE INTERNAL "")
				SET(LIBEVFIBERS_CFLAGS "" CACHE INTERNAL "")
				SET(LIBEVFIBERS_LDFLAGS "${LIBEVFIBERS_LIBDIR}/libevfibers.so" CACHE INTERNAL "")
				SET(LIBEVFIBERS_FOUND TRUE CACHE INTERNAL "Found libevfibers" FORCE)
			ELSE(HAVE_LIBEVFIBERS)
				MESSAGE(STATUS "Couldn't find libevfibers in ${LIBEVFIBERS_LIBDIR}")
			ENDIF(HAVE_LIBEVFIBERS)
		ELSE(HAVE_EVFIBERS_H)
			MESSAGE(STATUS "Couldn't find <evfibers/fiber.h> in ${LIBEVFIBERS_INCLUDE_PATH}")
		ENDIF(HAVE_EVFIBERS_H)
	ELSE(LIBEVFIBERS_INCLUDE_PATH OR LIBEVFIBERS_LIBDIR)
		pkg_check_modules(LIBEVFIBERS libevfibers)
		IF(NOT LIBEVFIBERS_FOUND)
			CHECK_INCLUDE_FILES(evfibers/fiber.h HAVE_EVFIBERS_H)
			IF(HAVE_EVFIBERS_H)
				CHECK_LIBRARY_EXISTS(evfibers fbr_alloc "" HAVE_LIBEVFIBERS)
				IF(HAVE_LIBEVFIBERS)
					SET(LIBEVFIBERS_CFLAGS "" CACHE INTERNAL "")
					SET(LIBEVFIBERS_LDFLAGS "-levfibers" CACHE INTERNAL "")
					SET(LIBEVFIBERS_FOUND TRUE CACHE INTERNAL "Found libevfibers" FORCE)
				ELSE(HAVE_LIBEVFIBERS)
					MESSAGE(STATUS "Couldn't find libevfibers")
				ENDIF(HAVE_LIBEVFIBERS)
			ELSE(HAVE_EVFIBERS_H)
				MESSAGE(STATUS "Couldn't find <evfibers/fiber.h>")
			ENDIF(HAVE_EVFIBERS_H)
		ENDIF(NOT LIBEVFIBERS_FOUND)
	ENDIF(LIBEVFIBERS_INCLUDE_PATH OR LIBEVFIBERS_LIBDIR)

ENDIF(NOT LIBEVFIBERS_FOUND)

IF(NOT LIBEVFIBERS_FOUND)
	IF(LibEV_FIND_REQUIRED)
		MESSAGE(FATAL_ERROR "Could not find libevfibers")
	ENDIF(LibEV_FIND_REQUIRED)
ENDIF(NOT LIBEVFIBERS_FOUND)

MARK_AS_ADVANCED(LIBEVFIBERS_PATH LIBEVFIBERS_INCLUDE_PATH LIBEVFIBERS_LIBDIR)
