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

#[[
connextdds_datamodels_convert_to_xml
------------------------------------

This function calls rtiddsgen to all IDL files included in the INPUT_FOLDERS.
Then, this function returns the generated files.

Input parameters:

``INPUT_FOLDERS`` (mandatory)
    Folder that contains the idl files to process.

``OUTPUT_FOLDER`` (mandatory)
    Folder that will contain the generated files.

``IGNORE_IDL_NAMES`` (optional)
    List of file names (without extension) that will be ignored and, therefore
    rtiddsgen will not generate code for.

``IDL_DEPENDENCIES_FOLDERS`` (optional)
    Folder that contains dependencies of the IDL files. For example if an IDL
    file has an #include "file.idl", this variable should contain the folder
    where file.idl is located.

``CODEGEN_EXTRA_ARGS`` (optional)
    Additional flags for Codegen.

 * How to use it:

    connextdds_datamodels_convert_to_xml(
        INPUT_FOLDERS "datamodel/idl"
        OUTPUT_FOLDER "${CMAKE_CURRENT_BINARY_DIR}/datamodel/xml"
        IGNORE_IDL_NAMES "ALMAS_Management_DLRL"
        IDL_DEPENDENCIES_FOLDERS "${DDS_DATAMODELS_UTILS_DIR}/dds"
        CODEGEN_EXTRA_ARGS "-verbosity" "1"
    )
]]

function(connextdds_datamodels_convert_to_xml)
    set(_BOOLEANS)
    set(_SINGLE_VALUE_ARGS OUTPUT_FOLDER)
    set(_MULTI_VALUE_ARGS
        INPUT_FOLDERS IGNORE_IDL_NAMES IDL_DEPENDENCIES_FOLDERS CODEGEN_EXTRA_ARGS)

    cmake_parse_arguments(_args
        "${_BOOLEANS}"
        "${_SINGLE_VALUE_ARGS}"
        "${_MULTI_VALUE_ARGS}"
        ${ARGN}
    )

    if(NOT DEFINED _args_INPUT_FOLDERS)
        message(FATAL_ERROR "Error in function connextdds_datamodels_generate_code() "
            "The mandatory parameter INPUT_FOLDERS is not defined.")
    endif()

    if(NOT DEFINED _args_OUTPUT_FOLDER)
        message(FATAL_ERROR "Error in function connextdds_datamodels_generate_code() "
            "The mandatory parameter OUTPUT_FOLDER is not defined.")
    endif()

    include(ConnextDdsCodegen)

    # Get the name of all the idl files under datamodel/idl/
    set(idl_files)
    foreach(input_folder in ${_args_INPUT_FOLDERS})
        file(GLOB idl_files_from_folder "${input_folder}/*.idl")
        list(APPEND idl_files ${idl_files_from_folder})
    endforeach()

    foreach(input_folder in ${_args_IDL_DEPENDENCIES_FOLDERS})
        file(GLOB idl_files_from_folder "${input_folder}/*.idl")
        list(APPEND idl_files ${idl_files_from_folder})
    endforeach()

    cmake_policy(SET CMP0057 NEW)

    # Call codegen to convert to XML all IDL files
    set(converted_idl_files)
    foreach(idl_file_path IN LISTS idl_files)
        get_filename_component(idl_name ${idl_file_path} NAME_WE)
        if(NOT idl_name IN_LIST _args_IGNORE_IDL_NAMES)
            message(STATUS "Generating XML for ${idl_file_path}")
            connextdds_rtiddsgen_convert(
                INPUT "${idl_file_path}"
                FROM "IDL"
                TO "XML"
                OUTPUT_DIRECTORY "${_args_OUTPUT_FOLDER}"
                INCLUDE_DIRS ${_args_IDL_DEPENDENCIES_FOLDERS}
                EXTRA_ARGS ${_args_CODEGEN_EXTRA_ARGS}
            )
            list(APPEND converted_idl_files "${_args_OUTPUT_FOLDER}/${idl_name}.xml")
        endif()
    endforeach()
    add_custom_target(dds_datamodels_xml_output_files ALL
        DEPENDS
            ${converted_idl_files}
    )

endfunction()
