# Configuring some global settings
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
## Multithreaded
if(MSVC)
    add_compile_options(/MP)
endif(MSVC)
## Versioning
set( HM_VERSION_MAJOR 0 )
set( HM_VERSION_MINOR 0 )
set( HM_VERSION_PATCH 1 )

set( HM_VERSION ${HM_VERSION_MAJOR}.${HM_VERSION_MINOR}.${HM_VERSION_PATCH})
## Setting the dlls and .exe in the same folder
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/$<CONFIG>)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/$<CONFIG>)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/$<CONFIG>)


# Asset function
set(ASSET_SOURCE_DIR "${CMAKE_SOURCE_DIR}/game/assets")
function(configure_assets_for target)


    set(ASSET_BINARY_DIR "$<TARGET_FILE_DIR:${target}>/assets")
    set(ASSET_SOLUTION_DIR "${CMAKE_CURRENT_BINARY_DIR}/assets")

    add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${ASSET_SOURCE_DIR}"
        "${ASSET_BINARY_DIR}"
    )
    add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${ASSET_SOURCE_DIR}"
        "${ASSET_SOLUTION_DIR}"
    )
endfunction()

# Generic addition of macro per backend
function(exec_macro_for target backend)
    foreach(backend IN LISTS backends)
        string(TOUPPER "${backend}" B_UP)
        target_compile_definitions(${target} PUBLIC
        "GAME_${B_UP}_EXECUTABLE_NAME=\"$<TARGET_FILE_NAME:game_${backend}>\""
            )
    endforeach()

endfunction()

function(add_game_backends backends)
    set(game_exes)

    foreach(backend IN LISTS backends)
        message(STATUS "  Generating targets for backend = ${backend}")
        set(target "game_${backend}")
        set(engine "hammered_engine_${backend}")

        add_executable(${target} game/src/main.cpp)
        target_link_libraries(${target} PRIVATE ${engine})
        add_dependencies(${engine} shaders)

        exec_macro_for(${target} "${backends}")
        exec_macro_for(${engine} "${backend}")

        set_property(TARGET ${target} PROPERTY CXX_STANDARD 20)
        configure_assets_for(${target})

        list(APPEND game_exes ${target})

    endforeach()

    # Compiler flags
    if(MSVC)
        set(CMAKE_CXX_FLAGS "/W4 /WX /EHsc")          # common flags for all configs
        set(CMAKE_CXX_FLAGS_DEBUG "/Zi /MTd /Od /Ob0 /DDEBUG")
        set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "/O2 /Zi /DDEVELOP /MT")
        set(CMAKE_CXX_FLAGS_RELEASE "/O2 /DNDEBUG /MT")
    endif()
    add_custom_target(build_all_backends ALL
        DEPENDS ${game_exes}
    )
    set_target_properties(build_all_backends PROPERTIES FOLDER "utilities")
endfunction()

