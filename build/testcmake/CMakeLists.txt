cmake_minimum_required( VERSION 3.2 FATAL_ERROR )
project( testcmake )
find_file( GLM_SETUP setup.hpp 
    PATHS /Volumes/DataD/deps/android/arm/include/glm/detail/
    NO_DEFAULT_PATH
)
message("the resutl is "${GLM_SETUP})
