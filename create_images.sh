#!/bin/sh

docker save --output=engineapi_image.tar juliabox/engineapi
docker save --output=webserver_image.tar juliabox/webserver
docker save --output=engineinteractive_image.tar juliabox/engineinteractive
docker save --output=enginedaemon_image.tar juliabox/enginedaemon
docker save --output=juliabox_image.tar juliabox/juliabox
docker save --output=julia_image.tar julialang/julia
docker save --output=enginebase_image.tar juliabox/enginebase
docker save --output=juliaboxapi_image.tar juliabox/juliaboxapi
