#!/bin/bash -eu

DIR=${1}

if [[ ! -d "${DIR}" ]]; then
    echo "${DIR} does not exist!"
    exit 1
fi

if [[ ! $# -eq 1 ]]; then
    echo 'provide just one argument!'
    exit 2
fi

for FILE in "${DIR}"/*; do

    if [[ -f ${FILE} && "${FILE##*.}" = "bak" ]]; then
        chmod g-w ${FILE} 
        chmod o-w ${FILE} 
        chmod a-w ${FILE} 
    fi
    
    if [[ -d ${FILE} && "${FILE##*.}" = "bak" ]]; then
        chmod g+x ${FILE}
        chmod a+x ${FILE}
        chmod o-x ${FILE}
        chmod o+r ${FILE}
        chmod a+r ${FILE}
        chmod g-r ${FILE}
    fi
   
    if [[ -d ${FILE} && "${FILE##*.}" = "tmp" ]]; then
        chmod 200 ${FILE}
    fi

    if [[ -f ${FILE} && "${FILE##*.}" = "txt" ]]; then
        chmod 241 ${FILE}     
    fi
done

