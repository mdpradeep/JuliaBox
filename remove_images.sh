#!/bin/sh 

DOCKER_IMAGES="juliabox/juliaboxapi juliabox/juliaboxapi:34 juliabox/juliabox:34 juliabox/juliabox juliabox/engineapi juliabox/engineinteractive juliabox/enginedaemon juliabox/enginebase juliabox/webserver julialang/julia:v0.3.11"

for dock_image in $DOCKER_IMAGES
do
    echo "Removing docker image $dock_image"
    ## docker rmi $dock_image
done
