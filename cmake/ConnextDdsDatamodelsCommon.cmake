###############################################################################
#  (c) 2024 Copyright, Real-Time Innovations, Inc. (RTI) All rights reserved. #
#                                                                             #
#  RTI grants Licensee a license to use, modify, compile, and create          #
#  derivative works of the software solely for use with RTI Connext DDS.      #
#  Licensee may redistribute copies of the software provided that all such    #
#  copies are subject to this license.                                        #
#  The software is provided "as is", with no warranty of any type, including  #
#  any warranty for fitness for any purpose. RTI is under no obligation to    #
#  maintain or support the software.  RTI shall not be liable for any         #
#  incidental or consequential damages arising out of the use or inability to #
#  use the software.                                                          #
#                                                                             #
###############################################################################

# This function transform a list of paths to absolute paths
function(convert_absolute_path_list list_of_paths)

    if(list_of_paths)
        set(dirs_full_path)

        foreach(dir IN LISTS ${list_of_paths})
            get_filename_component(absolute_dir "${dir}" ABSOLUTE)
            list(APPEND dirs_full_path ${absolute_dir})
        endforeach()

        # Override the list_of_paths variable in the parent scope with the results
        set(${list_of_paths} ${dirs_full_path} PARENT_SCOPE)
    endif()
endfunction()
