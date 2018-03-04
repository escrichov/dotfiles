#!/usr/bin/env bash


# tar alias
function tar-compress {
	DIR=$1
	tar -zcf $DIR.tar.gz $DIR
}

alias tar-decompress='tar -zxf'

function search-content {
    DIR=$1
    PATTERN=$2

    if [ -z $DIR ] || [ -z $PATTERN ];then
        echo "Usage: $0 [directory] [pattern]"
        return 1
    fi

    grep -R "$PATTERN" $DIR 2> /dev/null
}

function search-files {
    DIR=$1
    PATTERN=$2

    if [ -z $DIR ] || [ -z $PATTERN ];then
        echo "Usage: $0 [directory] [pattern]"
        return 1
    fi

    find $DIR -iname "$PATTERN" 2> /dev/null
}

function remux {
    INPUT=$1
    OUTPUT=$2

    if [ -z $INPUT ] || [ -z $OUTPUT ];then
        echo "Usage: $0 [input.avi] [output.mp4]"
        return 1
    fi

    ffmpeg -i $INPUT -c:v copy -c:a copy $OUTPUT
}

# Coloring man pages
man() {
    LESS_TERMCAP_mb=$'\e'"[1;31m" \
    LESS_TERMCAP_md=$'\e'"[1;31m" \
    LESS_TERMCAP_me=$'\e'"[0m" \
    LESS_TERMCAP_se=$'\e'"[0m" \
    LESS_TERMCAP_so=$'\e'"[1;44;33m" \
    LESS_TERMCAP_ue=$'\e'"[0m" \
    LESS_TERMCAP_us=$'\e'"[1;32m" \
    command man "$@"
}
