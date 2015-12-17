#!/bin/sh 

## MDP VER=v0.3
## MDP FULL_VER=v0.3.11
VER=v0.4
FULL_VER=v0.4.1

DOCKER_IMAGES="juliabox/juliaboxapi juliabox/juliaboxapi:34 juliabox/juliabox:34 juliabox/juliabox juliabox/engineapi juliabox/engineinteractive juliabox/enginedaemon juliabox/enginebase juliabox/webserver"

## julialang/julia:${FULL_VER}"

for dock_image in $DOCKER_IMAGES
do
    echo "Removing docker image $dock_image"
    docker rmi -f $dock_image
done
