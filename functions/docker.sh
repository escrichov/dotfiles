#!/usr/bin/env bash


function docker-machine-env {
    MACHINE=$1
    eval $(docker-machine env ${MACHINE})
}

alias docker-ps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'

# Docker alias
function docker-clean {
    CONTAINERS=$(docker ps -a -q)
    if [ ! -z $CONTAINERS ]; then
        docker rm -f $(docker ps -a -q)
    fi

    VOLUMES=$(docker volume ls -qf dangling=true)
    if [ ! -z $VOLUMES ]; then
        docker volume rm -f $(docker volume ls -qf dangling=true)
    fi
}

function docker-clean-images {
    CONTAINERS=$(docker images -a -q)
    if [ ! -z $CONTAINERS ]; then
        docker rmi -f $(docker images -a -q)
    fi
}

function docker-set {
    DOMAIN=$1
    PORT=$2
    TLS_PATH=$3
    TLS_VERIFY="1"

    if [ -z $DOMAIN ];then
        echo "Usage: docker_set domain [port] [tls_path]"
        return 1
    fi

    if [ -z $PORT ];then
        PORT=8376
    fi

    if [ -z $TLS_PATH ];then
        TLS_PATH=$HOME/All/Baintex/docker_certs
    fi

    export DOCKER_TLS_VERIFY="$TLS_VERIFY"
    export DOCKER_CERT_PATH="$TLS_PATH"
    export DOCKER_HOST="tcp://$DOMAIN:$PORT"
}


function docker-machine-create {
    MACHINE_IP=$1
    MACHINE_USER=$2
    MACHINE_NAME=$3

    docker-machine create -d generic \
    --generic-ip-address=$MACHINE_IP \
    --generic-ssh-user=$MACHINE_USER \
    --engine-storage-driver=devicemapper \
    $MACHINE_NAME
}
