# bgfx.cmake - bgfx building in cmake
# Written in 2017 by Joshua Brookover <joshua.al.brookover@gmail.com>

# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.

# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

cmake_minimum_required( VERSION 3.0 )
project( bgfx )

set_property( GLOBAL PROPERTY USE_FOLDERS ON )
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Makefile generators on apple need this flag to compile mixed objective/c++
if( APPLE AND NOT XCODE )
	set( CMAKE_CXX_FLAGS "-ObjC++" )
elseif(MSVC)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP${NB_PROCS}")
endif()

option( BGFX_BUILD_TOOLS      "Build bgfx tools."                             ON  )
option( BGFX_SHADERC_LIB      "Build shaderc tools as a lib."                 ON  )
option( BGFX_BUILD_EXAMPLES   "Build bgfx examples."                          ON  )
option( BGFX_INSTALL          "Create installation target."                   ON  )
option( BGFX_INSTALL_EXAMPLES "Install examples and their runtimes."          OFF )
option( BGFX_CUSTOM_TARGETS   "Include convenience custom targets."           ON  )
option( BGFX_USE_OVR          "Build with OVR support."                       OFF )
option( BGFX_AMALGAMATED      "Amalgamated bgfx build for faster compilation" OFF )
option( BX_AMALGAMATED        "Amalgamated bx build for faster compilation"   OFF )
option( BGFX_CONFIG_DEBUG     "Enables debug configuration on all builds"     OFF )
option( BGFX_USE_DEBUG_SUFFIX "Add 'd' suffix to debug output targets"        OFF  )
set( BGFX_OPENGL_VERSION  "" CACHE STRING "Specify minimum opengl version" )

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
	set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/bgfx-install)
endif()

set(CMAKE_DEBUG_POSTFIX "d" CACHE STRING "add a debug postfix globally")
set(CMAKE_RELWITHDEBINFO_POSTFIX "rd" CACHE STRING "add a release with debug postfix globally")

if( NOT BX_DIR )
	set( BX_DIR "${CMAKE_CURRENT_SOURCE_DIR}/bx" CACHE STRING "Location of bx." )
elseif( NOT IS_ABSOLUTE "${BX_DIR}")
	get_filename_component(BX_DIR "${BX_DIR}" REALPATH BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
endif()
if( NOT BIMG_DIR )
	set( BIMG_DIR "${CMAKE_CURRENT_SOURCE_DIR}/bimg" CACHE STRING "Location of bimg." )
elseif( NOT IS_ABSOLUTE "${BIMG_DIR}")
	get_filename_component(BIMG_DIR "${BIMG_DIR}" REALPATH BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
endif()
if( NOT BGFX_DIR )
	set( BGFX_DIR "${CMAKE_CURRENT_SOURCE_DIR}/bgfx" CACHE STRING "Location of bgfx." )
elseif( NOT IS_ABSOLUTE "${BGFX_DIR}")
	get_filename_component(BGFX_DIR "${BGFX_DIR}" REALPATH BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
endif()

if( BGFX_USE_OVR )
	include( cmake/ovr.cmake )
endif()

include( cmake/shared.cmake )
include( cmake/bx.cmake )
include( cmake/bimg.cmake )
include( cmake/bgfx.cmake )

if( BGFX_BUILD_TOOLS )
	include( cmake/tools.cmake )
endif()

include( cmake/examples.cmake )

if( BGFX_INSTALL )
	include(GNUInstallDirs)

	# install bx
	install( TARGETS bx
		EXPORT bgfx-config
		ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} )
	install( DIRECTORY ${BX_DIR}/include DESTINATION . )

	# install bimg
	install( TARGETS bimg
		EXPORT bgfx-config
		ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} )
	install( DIRECTORY ${BIMG_DIR}/include DESTINATION . )

	# install bgfx
	install( TARGETS bgfx
		EXPORT bgfx-config
		ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} )
	install( DIRECTORY ${BGFX_DIR}/include DESTINATION . )

        # install shaderclib
        install( TARGETS shaderclib
                ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
        install( DIRECTORY ${BGFX_DIR}/tools/shaderc DESTINATION  include/tools/)

        # install export
	install(
		EXPORT bgfx-config
		NAMESPACE bgfx::
		DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/bgfx)

	install( FILES ${BGFX_DIR}/src/bgfx_shader.sh
		DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/bgfx"
	)

	# install tools
	if( BGFX_BUILD_TOOLS )
		install( TARGETS shaderc
			EXPORT bgfx-config
			DESTINATION bin )

		if(BGFX_SHADERC_LIB)
			set(SHADERC_DEPS bgfx-vertexdecl bgfx-shader-spirv fcpp glsl-optimizer glslang spirv-cross spirv-tools shaderclib)
			foreach(SHADERC_DEP ${SHADERC_DEPS})
				install( TARGETS ${SHADERC_DEP}
					EXPORT shaderc-config
					ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
			endforeach()
			install( FILES ${BGFX_DIR}/tools/shaderc/shaderc.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/shaderc )
		endif()

		install( TARGETS geometryc
			EXPORT bgfx-config
			DESTINATION bin )
		install( TARGETS texturec
			EXPORT bgfx-config
			DESTINATION bin )
		install( TARGETS texturev
			EXPORT bgfx-config
			DESTINATION bin )
	endif()

	# install examples
	if( BGFX_BUILD_EXAMPLES AND BGFX_INSTALL_EXAMPLES )
		install( DIRECTORY ${BGFX_DIR}/examples/runtime/ DESTINATION examples )
		foreach( EXAMPLE ${BGFX_EXAMPLES} )
			install( TARGETS example-${EXAMPLE} DESTINATION examples )
		endforeach()
	endif()
endif()
