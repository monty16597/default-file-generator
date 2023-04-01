#!/bin/bash
set -e

function add_file {
    _work_dir=$1
    if [ ! -d "${_work_dir%%/}" ]; then
        mkdir -p "${_work_dir%%/}"
        echo "${_work_dir%%/} directory does not exist. Created."
    elif [ -f "${_work_dir%%/}/${INPUT_FILE_NAME}" ]; then
        if [[ $INPUT_OVERRIDE_CONTENT != 'true' ]]; then
            echo "Override option is disable. Please pass it true."
        else
            echo $INPUT_FILE_CONTENT > "${_work_dir%%/}/${INPUT_FILE_NAME}"
            echo "${_work_dir%%/}/${INPUT_FILE_NAME} file content changed"
        fi
    else
        touch "${_work_dir%%/}/${INPUT_FILE_NAME}"
        echo $INPUT_FILE_CONTENT > "${_work_dir%%/}/${INPUT_FILE_NAME}"
        echo "${_work_dir%%/}/${INPUT_FILE_NAME} file created"
    fi
}

if [[ $INPUT_RECURSIVE == 'true' ]]; then
    echo "Recursive enabled"
    if [[ $INPUT_RECURSIVE_INCLUDE_WORK_DIR == 'true' ]]; then
        DIRECTORIES=$(find $INPUT_WORK_DIR -maxdepth $INPUT_RECURSIVE_DEPTH -type d)
    else
        DIRECTORIES=$(find $INPUT_WORK_DIR -maxdepth $INPUT_RECURSIVE_DEPTH ! -path $INPUT_WORK_DIR -type d)
    fi
    for dir in $DIRECTORIES;
    do
        add_file "$dir"
    done
else
    add_file "$INPUT_WORK_DIR"
fi