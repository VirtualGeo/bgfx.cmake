# bgfx.cmake - bgfx building in cmake
# Written in 2017 by Joshua Brookover <joshua.al.brookover@gmail.com>
#
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

if(EMSCRIPTEN)
	set(SHADERC_SOURCES    
		${BGFX_DIR}/tools/shaderc/shaderc.cpp
		${BGFX_DIR}/tools/shaderc/shaderc.h
		${BGFX_DIR}/tools/shaderc/shaderc_glsl.cpp
	)
else()
	set(SHADERC_SOURCES    
		${BGFX_DIR}/tools/shaderc/shaderc.cpp
		${BGFX_DIR}/tools/shaderc/shaderc.h
		${BGFX_DIR}/tools/shaderc/shaderc_glsl.cpp
		${BGFX_DIR}/tools/shaderc/shaderc_hlsl.cpp
		${BGFX_DIR}/tools/shaderc/shaderc_pssl.cpp
		#${BGFX_DIR}/tools/shaderc/shaderc_spirv.cpp
		#${BGFX_DIR}/tools/shaderc/shaderc_metal.cpp
		#${BGFX_DIR}/src/shader.h
		#${BGFX_DIR}/src/shader.cpp
		# ${BGFX_DIR}/src/shader_dx9bc.h
		# ${BGFX_DIR}/src/shader_dx9bc.cpp
		# ${BGFX_DIR}/src/shader_dxbc.h
		# ${BGFX_DIR}/src/shader_dxbc.cpp
		# ${BGFX_DIR}/src/shader_spirv.h
		# ${BGFX_DIR}/src/shader_spirv.cpp
	)
endif()
add_library(shaderclib SHARED ${SHADERC_SOURCES})

target_compile_definitions( shaderclib PRIVATE "SHADERC_LIB" )
if(MSVC)
	target_compile_definitions( shaderclib PRIVATE "_CRT_SECURE_NO_WARNINGS" )
endif()

if(EMSCRIPTEN)
	target_link_libraries(
		shaderclib
		PRIVATE bx
				bimg
				bgfx-vertexlayout
				fcpp
				glsl-optimizer
	)
else()
	target_link_libraries(
		shaderclib
		PRIVATE bx
				bimg
				bgfx-vertexlayout
				fcpp
				glslang
				glsl-optimizer
				spirv-opt
				spirv-cross
				webgpu
	)
endif()

if(BGFX_AMALGAMATED)
	target_link_libraries(shaderclib PRIVATE bgfx-shader)
endif()

set_target_properties( shaderclib PROPERTIES DEBUG_POSTFIX d RELWITHDEBINFO_POSTFIX rd )

set_target_properties(
	shaderclib PROPERTIES FOLDER "bgfx/tools" #
					   OUTPUT_NAME ${BGFX_TOOLS_PREFIX}shaderclib #
)

if(ANDROID)
	target_link_libraries(shaderclib PRIVATE log)
elseif(IOS)
	set_target_properties(shaderclib PROPERTIES MACOSX_BUNDLE ON MACOSX_BUNDLE_GUI_IDENTIFIER shaderclib)
endif()

if(BGFX_INSTALL)
	install(
		TARGETS shaderclib
		EXPORT "${TARGETS_EXPORT_NAME}"
		LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
		ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
		RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
	)
	install(FILES ${BGFX_DIR}/tools/shaderc/shaderc.h DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/shaderc")
endif()
