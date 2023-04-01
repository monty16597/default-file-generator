#!/bin/bash
set -e

git_setup() {
    # When the runner maps the $GITHUB_WORKSPACE mount, it is owned by the runner
    # user while the created folders are owned by the container user, causing this
    # error. Issue description here: https://github.com/actions/checkout/issues/766
    git config --global --add safe.directory /github/workspace

    git config --global user.name "${INPUT_GIT_PUSH_USER_NAME}"
    git config --global user.email "${INPUT_GIT_PUSH_USER_EMAIL}"
    git fetch --depth=1 origin +refs/tags/*:refs/tags/* || true
}

git_add() {
    local file
    file="$1"
    git add "${file}"
    if [ "$(git status --porcelain | grep "$file" | grep -c -E '([MA]\W).+')" -eq 1 ]; then
        echo "Added ${file} to git staging area"
    else
        echo "No change in ${file} detected"
    fi
}

git_status() {
    git status --porcelain | grep -c -E '([MA]\W).+' || true
}

git_commit() {
    if [ "$(git_status)" -eq 0 ]; then
        echo "No files changed, skipping commit"
        exit 0
    fi

    echo "Following files will be committed"
    git status -s

    local args=(
        -m "${INPUT_GIT_COMMIT_MESSAGE}"
    )

    git commit "${args[@]}"
}


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

git_setup
echo "######"
echo $INPUT_FILE_CONTENT
echo "######"

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
        git_add "${dir%%/}/${INPUT_FILE_NAME}"
    done
else
    add_file "$INPUT_WORK_DIR"
    git_add "${INPUT_WORK_DIR%%/}/${INPUT_FILE_NAME}"
fi

git_commit
# git push
