ExternalProject_Add(shaderc
    DEPENDS
        glslang
        spirv-headers
        spirv-tools
    GIT_REPOSITORY https://github.com/google/shaderc.git
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_REMOTE_NAME origin
    GIT_TAG main
    GIT_CLONE_FLAGS "--filter=tree:0"
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} cmake -H<SOURCE_DIR> -B<BINARY_DIR>
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX=${MINGW_INSTALL_PREFIX}
        -DCMAKE_TOOLCHAIN_FILE=<SOURCE_DIR>/cmake/linux-mingw-toolchain.cmake
        -DSHADERC_SKIP_TESTS=ON
        -DSHADERC_SKIP_SPVC=ON
        -DSHADERC_SKIP_INSTALL=ON
        -DSHADERC_SKIP_EXAMPLES=ON
        -DMINGW_COMPILER_PREFIX=${TARGET_ARCH}
        -DCMAKE_CXX_FLAGS='${CMAKE_CXX_FLAGS} -std=c++11'
        -DEXTRA_STATIC_PKGCONFIG_LIBS='-lglslang -lSPIRV-Tools -lSPIRV-Tools-opt'
    BUILD_COMMAND ${MAKE} -C <BINARY_DIR>
    INSTALL_COMMAND ""
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

get_property(src_glslang TARGET glslang PROPERTY _EP_SOURCE_DIR)
get_property(src_spirv-headers TARGET spirv-headers PROPERTY _EP_SOURCE_DIR)
get_property(src_spirv-tools TARGET spirv-tools PROPERTY _EP_SOURCE_DIR)

ExternalProject_Add_Step(shaderc symlink
    DEPENDEES download update patch
    DEPENDERS configure
    WORKING_DIRECTORY <SOURCE_DIR>/third_party
    COMMAND ${CMAKE_COMMAND} -E create_symlink ${src_glslang} glslang
    COMMAND ${CMAKE_COMMAND} -E create_symlink ${src_spirv-headers} spirv-headers
    COMMAND ${CMAKE_COMMAND} -E create_symlink ${src_spirv-tools} spirv-tools
    COMMENT "Symlinking glslang, spirv-headers, spirv-tools"
)

ExternalProject_Add_Step(shaderc manual-install
    DEPENDEES build
    COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/libshaderc/include/shaderc ${MINGW_INSTALL_PREFIX}/include/shaderc
    COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/libshaderc_util/include/libshaderc_util ${MINGW_INSTALL_PREFIX}/include/libshaderc_util
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libshaderc/libshaderc.a ${MINGW_INSTALL_PREFIX}/lib/libshaderc.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libshaderc_util/libshaderc_util.a ${MINGW_INSTALL_PREFIX}/lib/libshaderc_util.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/shaderc_static.pc ${MINGW_INSTALL_PREFIX}/lib/pkgconfig/shaderc.pc
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libshaderc/libshaderc_combined.a ${MINGW_INSTALL_PREFIX}/lib/libshaderc_combined.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/shaderc_combined.pc ${MINGW_INSTALL_PREFIX}/lib/pkgconfig/shaderc_combined.pc
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/glslc/libglslc.a ${MINGW_INSTALL_PREFIX}/lib/libglslc.a

    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/third_party/spirv-tools/source/libSPIRV-Tools.a ${MINGW_INSTALL_PREFIX}/lib/libSPIRV-Tools.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/third_party/spirv-tools/source/opt/libSPIRV-Tools-opt.a ${MINGW_INSTALL_PREFIX}/lib/libSPIRV-Tools-opt.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/third_party/spirv-tools/SPIRV-Tools.pc ${MINGW_INSTALL_PREFIX}/lib/pkgconfig/SPIRV-Tools.pc

    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/third_party/glslang/glslang/libglslang.a ${MINGW_INSTALL_PREFIX}/lib/libglslang.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/third_party/glslang/glslang/libGenericCodeGen.a ${MINGW_INSTALL_PREFIX}/lib/libGenericCodeGen.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/third_party/glslang/glslang/libglslang-default-resource-limits.a ${MINGW_INSTALL_PREFIX}/lib/libglslang-default-resource-limits.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/third_party/glslang/hlsl/libHLSL.a ${MINGW_INSTALL_PREFIX}/lib/libHLSL.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/third_party/glslang/glslang/libMachineIndependent.a ${MINGW_INSTALL_PREFIX}/lib/libMachineIndependent.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/third_party/glslang/OGLCompilersDLL/libOGLCompiler.a ${MINGW_INSTALL_PREFIX}/lib/libOGLCompiler.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/third_party/glslang/glslang/OSDependent/Windows/libOSDependent.a ${MINGW_INSTALL_PREFIX}/lib/libOSDependent.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/third_party/glslang/SPIRV/libSPIRV.a ${MINGW_INSTALL_PREFIX}/lib/libSPIRV.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/third_party/glslang/SPIRV/libSPVRemapper.a ${MINGW_INSTALL_PREFIX}/lib/libSPVRemapper.a

    COMMENT "Manually installing"
)

force_rebuild_git(shaderc)
