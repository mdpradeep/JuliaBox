#!/bin/sh 

## MDP VER=v0.3
## MDP FULL_VER=v0.3.11
VER=v0.4
FULL_VER=v0.4.1


echo "======================================================"
echo "Stopping containers ..."
echo "======================================================"
./JuliaDeployment/scripts/run/stop.sh
ret_val=$?

echo "======================================================"
if [ $ret_val -eq 0 ]
then
    echo "Stopped the containers"
else
    echo "Could not stop the containers ... "
    ## Not exiting here. It might be that the containers were not running !
    ## exit 1
fi
echo "======================================================"

echo "======================================================"
echo "Removing docker images ..."
echo "======================================================"
DOCKER_IMAGES="juliabox/juliaboxapi juliabox/juliaboxapi:34 juliabox/juliabox:34 juliabox/juliabox juliabox/engineapi juliabox/engineinteractive juliabox/enginedaemon juliabox/enginebase juliabox/webserver julialang/julia:${FULL_VER}

for dock_image in $DOCKER_IMAGES
do
    echo "Removing docker image $dock_image"
    docker rmi $dock_image
done

echo "======================================================"
echo "Removed docker images ..."
echo "======================================================"

echo "======================================================"
echo "Removing old data ..."
echo "======================================================"

JBOXENGINE_FOLDER="/jboxengine"
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
## echo "Current Time : $current_time"
 
JBOXENGINE_FOLDER_BAK=$JBOXENGINE_FOLDER.$current_time
\mv $JBOXENGINE_FOLDER $JBOXENGINE_FOLDER_BAK

echo "======================================================"
echo "Removed old data ..."
echo "======================================================"

