#!/bin/bash -eu

DIR1=${1:=}
DIR2=${2:-}

if [[ ! $# -eq 2 ]] ; then
    echo 'enter 2 arguments'
    exit 1
fi

if [[ ! -d ${DIR1} ]]; then
    echo "${DIR1} does not exist"
    exit 1
fi

if [[ ! -d ${DIR2} ]]; then
    echo "${DIR2} does not exist"
    exit 1
fi



NAMES=$(ls ${DIR1})
for NAME in ${NAMES}
do
    if [[ -d ${DIR1}/${NAME} ]]; then
        echo "${NAME} is a directory"
        TEMP="${NAME^^}"
        ln -s ../${DIR1}/${NAME} ./${DIR2}/${TEMP}_ln  
    fi
    if [[ -f ${DIR1}/${NAME}  ]]; then
        echo "${NAME} is a regular file"
        TEMP="${NAME%.*}."
        TEMP="${TEMP^^}"
        TEMP="${TEMP/./_ln.}"
        TEMP="${TEMP}${NAME#*.}"
        ln -s ../${DIR1}/${NAME} ./${DIR2}/${TEMP}
    fi
    if [[ -L ${DIR1}/${NAME}  ]]; then
        echo "${NAME} is a symbolic link"
    fi
done
