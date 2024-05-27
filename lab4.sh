#!/bin/bash -eu

function print_help () {
    echo "This script allows to search over movies database"
    echo -e "-d DIRECTORY\n\tDirectory with files describing movies"
    echo -e "-a ACTOR\n\tSearch movies that this ACTOR played in"
    echo -e "-t QUERY\n\tSearch movies with given QUERY in title"
    echo -e "-y YEAR\n\tSearch movies that were made after YEAR"
    echo -e "-f FILENAME\n\tSaves results to file (default: results.txt)"
    echo -e "-x\n\tPrints results in XML format"
    echo -e "-h\n\tPrints this help message"
}

function print_error () {
    echo -e "\e[31m\033[1m${*}\033[0m" >&2
}

function get_movies_list () {
    local -r MOVIES_DIR=${1}
    local -r MOVIES_LIST=$(cd "${MOVIES_DIR}" && realpath ./*)
    echo "${MOVIES_LIST}"
}

function query_title () {
    # Returns list of movies from ${1} with ${2} in title slot
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        if grep "| Title" "${MOVIE_FILE}" | grep -q "${QUERY}"; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

function query_actor () {
    # Returns list of movies from ${1} with ${2} in actor slot
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        if grep "| Actors" "${MOVIE_FILE}" | grep -q "${QUERY}"; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

#+1.0 opcja ROK
function query_year () {
    # Returns list of movies from ${1} made after the year ${2}
    local -r MOVIES_LIST=${1}
    local -r YEAR=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        local VAR1
        VAR1="$(grep '| Year:' "$MOVIE_FILE" | grep -E -o '[0-9]{4}')"
        if [[ "${VAR1}" -gt "${YEAR}" ]]; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

function print_movies () {
    local -r MOVIES_LIST=${1}
    local -r OUTPUT_FORMAT=${2}

    for MOVIE_FILE in ${MOVIES_LIST}; do
        if [[ "${OUTPUT_FORMAT}" == "xml" ]]; then
            print_xml_format "${MOVIE_FILE}"
        else
            cat "${MOVIE_FILE}"
        fi
    done
}

function print_xml_format () {
    local -r FILENAME=${1}

    local TEMP
    TEMP=$(cat "${FILENAME}")

    # TODO: replace first line of equals signs

    # TODO: change 'Author:' into <Author>
    # TODO: change others too

    # append tag after each line
    TEMP=$(echo "${TEMP}" | sed -r 's/([A-Za-z]+).*/\0<\/\1>/')

    # replace the last line with </movie>
    TEMP=$(echo "${TEMP}" | sed '$s/===*/<\/movie>/')

    echo "${TEMP}"
}

#+1.0 adding txt
function add_txt_ext (){

    if [[ ${1: -4} != ".txt" ]]; then
        local add_txt="${1}.txt"
        echo "${add_txt}"
    else
        echo "${1}"
    fi
}


while getopts ":hd:t:a:f:x:y:" OPT; do
    case ${OPT} in
        h)
            print_help
            exit 0
            ;;
        d)
            MOVIES_DIR=${OPTARG}
            ;;
        t)
            SEARCHING_TITLE=true
            QUERY_TITLE=${OPTARG}
            ;;
        f)
            fixtxt=$( add_txt_ext "${OPTARG}" )
            FILE_4_SAVING_RESULTS=${fixtxt}
            ;;
        a)
            SEARCHING_ACTOR=true
            QUERY_ACTOR=${OPTARG}
            ;;
        x)
            OUTPUT_FORMAT="xml"
            ;;
        y)
            SEARCHING_YEAR=true
            QUERY_YEAR=${OPTARG}
            ;;
        \?)
            print_error "ERROR: Invalid option: -${OPTARG}"
            exit 1
            ;;
    esac
done

# +1.0 dodaj spr, czy -d i katalog
if [[ -d ${MOVIES_DIR} ]]; then

    MOVIES_LIST=$(get_movies_list "${MOVIES_DIR}")

    if ${SEARCHING_TITLE:-false}; then
        MOVIES_LIST=$(query_title "${MOVIES_LIST}" "${QUERY_TITLE}")
    fi

    if ${SEARCHING_ACTOR:-false}; then
        MOVIES_LIST=$(query_actor "${MOVIES_LIST}" "${QUERY_ACTOR}")
    fi

    if ${SEARCHING_YEAR:-false}; then
        MOVIES_LIST=$(query_year "${MOVIES_LIST}" "${QUERY_YEAR}")
    fi

    if [[ "${#MOVIES_LIST}" -lt 1 ]]; then
        echo "Found 0 movies :-("
        exit 0
    fi

    if [[ "${FILE_4_SAVING_RESULTS:-}" == "" ]]; then
        print_movies "${MOVIES_LIST}" "${OUTPUT_FORMAT:-raw}"
    else
        print_movies "${MOVIES_LIST}" "${OUTPUT_FORMAT:-raw}" | tee "${FILE_4_SAVING_RESULTS}"
    fi

else
	echo "wrong input"
fi