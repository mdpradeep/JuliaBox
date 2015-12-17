#!/bin/sh

docker save --output=engineapi_image.tar juliabox/engineapi
docker save --output=webserver_image.tar juliabox/webserver
docker save --output=engineinteractive_image.tar juliabox/engineinteractive
docker save --output=enginedaemon_image.tar juliabox/enginedaemon
docker save --output=juliabox_image.tar juliabox/juliabox
docker save --output=julia_image.tar julialang/julia
docker save --output=enginebase_image.tar juliabox/enginebase
docker save --output=juliaboxapi_image.tar juliabox/juliaboxapi



## DOCKER_IMAGES="juliabox/juliaboxapi juliabox/juliabox juliabox/engineapi juliabox/engineinteractive juliabox/enginedaemon juliabox/enginebase juliabox/webserver"
DOCKER_IMAGES=`ls -1 *.tar`

for dock_image in $DOCKER_IMAGES
do
    echo "zipping up docker image $dock_image"
    gzip -9 $dock_image
done


