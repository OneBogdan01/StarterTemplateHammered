cmake_minimum_required(VERSION 3.24.0)


include(FetchContent)
## Keep it tidy
include(cmake_utility/utility.cmake)

project(hammered_template VERSION ${HM_VERSION})


# Backend selection
set(GAME_BACKENDS "")

option(ENABLE_GL_BACKEND "Build with OpenGL backend" ON)
option(ENABLE_VK_BACKEND "Build with Vulkan backend" ON)
if(ENABLE_GL_BACKEND)
    list(APPEND GAME_BACKENDS gl)
endif()

if(ENABLE_VK_BACKEND)
    list(APPEND GAME_BACKENDS vk)
endif()


# Error if no backends enabled
if(NOT GAME_BACKENDS)
    message(FATAL_ERROR "No game backend enabled! Enable at least one of ENABLE_GL_BACKEND or ENABLE_VK_BACKEND")
endif()

# Adds engine code and externals
add_subdirectory(engine)

# This is where it compiles shaders to .spv
add_subdirectory(game)
# Sets up the backends .exes
add_game_backends("${GAME_BACKENDS}")

# Set the Visual Studio startup project to the first enabled backend executable
list(GET GAME_BACKENDS 0 first_backend)
set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT "game_${first_backend}")

