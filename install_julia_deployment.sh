#!/bin/sh

### The purpose of this script is to load the various docker images and to extract the components to the right location
### set the right permissions, etc.

### This script is meant to be used the first time around for clean installation

## Untar up all the required images and components in the home folder
tar xvf JuliaDeploymentBundle.tar


cd JuliaDeploymentImages


## Load all the docker images

for dock_img in `ls -1 *_image.tar`
do
	echo ""
    echo "======================================================"
    echo "Loading docker image ${dock_img} ..."
    echo "======================================================"
	docker load < $dock_img
	ret_val=$?
    echo "======================================================"
    echo "Loaded docker image ${dock_img} ..."
    echo "Status ${ret_val} ..."  ## Should exit if not successful !
    echo "======================================================"
done

## Go back to where it all started
cd ../

echo "======================================================"
echo "Unpack jboxengine ..."
echo "======================================================"
\cp -rf jboxengine /
ret_val=$?
## TODO check if it is required to change ownership. It may not be required?
chown -R $USER:$USER /jboxengine
echo "======================================================"
echo "Unpacked jboxengine ..."
echo "Status ${ret_val} ..."  ## Should exit if not successful !
echo "======================================================"


echo "======================================================"
echo "Starting components ..."
echo "======================================================"

cd JuliaDeployment
./scripts/run/start.sh
ret_val=$?

echo "======================================================"
echo "Started components. ..."
echo "Status ${ret_val} ..."  ## Should exit if not successful !
echo "======================================================"


echo "======================================================"
echo "Validating components ..."
echo "======================================================"

num_containers=`docker ps -a | wc -l`

echo "======================================================"
if [$num_containers -ge 4]; then
	echo "Validation Successful !!!"
else
	echo "Validation Failed !!! Please check the log files for more information"
fi
echo "======================================================"


echo "======================================================"
echo "Validating API container ..."
echo "======================================================"

## TODO make a curl call to echo server to test the API container deployment

retVal=`curl -v --data ";jsonString=\"Hello\""  http://api.ip-10-93-140-37/test/echo/ | cat - | grep "Hello" | wc -l`

echo "The retVal is :: $retVal"

echo "======================================================"
if [$ret_val != 0]; then
	echo "API Deployment Successful !!!"
else
	echo "API Deployment Failed !!! Please check the log files for more information"
fi
echo "======================================================"

echo
echo "Installation and Validation DONE !!!"
