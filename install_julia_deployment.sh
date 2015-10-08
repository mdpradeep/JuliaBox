#!/bin/sh

### The purpose of this script is to load the various docker images and to extract the components to the right location
### set the right permissions, etc.

### This script is meant to be used the first time around for clean installation

### Perform pre-requisites check ...
owner=`who -m | awk '{print $1;}'`
## echo "The owner is $owner"
grep "^$owner:" /etc/passwd | grep "1000:1000" > /dev/null 2>&1
ret_val=$?
if [ "$ret_val" -eq 0 ]; then
    echo "Found the owner $owner with right UID and GID"
else
    echo "Did not find the owner $owner with right UID and GID"
    exit 1
fi

id | grep root > /dev/null 2>&1
ret_val=$?
if [ "$ret_val" -ne 0 ]; then
    echo "You are not running as sudo !!!"
    exit 1
else
    echo "Running as root. Continuing !!!"
fi


PRE_REQUISITE_APPS="docker supervisord supervisorctl"

check_availability() {
    command -v $1 > /dev/null 2>&1
    ret_val=$?
    ## echo "The ret_val is :: $ret_val"
    return $ret_val
}

for req_app in $PRE_REQUISITE_APPS
do
    ## echo $req_app
    check_availability $req_app
    ret_val=$?
    if [ $ret_val -eq 0 ]
    then
        echo "$req_app is installed, good to go !"
    else
        echo "$req_app is not installed. Please install $req_app first !"
        echo "Installation terminated as dependencies are not met."
        exit 1
    fi
done

add_host_to_etc_hosts() {
    hostname=`hostname`
    ## echo "The host name is ::: $hostname"
    ip_address=`ping -c 1 $hostname | grep "bytes of data" | awk '{print $3}' | cut -c 2- | rev | cut -c 2- | rev`
    ## echo "The ip address is $ip_address"
    string_to_add="$ip_address $hostname  api.$hostname"
    already_exists=`grep "^$string_to_add" /etc/hosts | wc -l`

    ## Check if already exists
    if [ $already_exists -ge 1 ]; then
         return 999
    fi
    echo "String to add is :: $string_to_add"
    echo "$string_to_add" >>  /etc/hosts
    return $?
}

## echo "Calling add_host_to_etc_hosts()"
add_host_to_etc_hosts
ret_val=$?
if [ $ret_val -eq 0 ]; then
    echo "added to /etc/hosts !"
elif [ $ret_val -eq 999 ]; then
    echo "already configured in /etc/hosts !"
else
    echo "could not add to /etc/hosts !"
    echo "Installation terminated as dependencies are not met."
    exit 1
fi

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
echo "Started components. Check webserver/logs and engine/logs ..."
echo "Status ${ret_val} ..."  ## Should exit if not successful !
echo "======================================================"


echo "======================================================"
echo "Validating components ..."
echo "======================================================"

echo "Waiting for components to start !"
sleep 5
num_containers=`docker ps -a | wc -l`
echo "# of containers = $num_containers"
echo "======================================================"
if [ $num_containers -ge 4 ]; then
	echo "Validation Successful !!!"
else
	echo "Validation Failed !!! Please check the log files for more information"
fi
echo "======================================================"


echo "======================================================"
echo "Validating API container ..."
echo "======================================================"

ret_val=`curl -v --data ";jsonString=\"Hello\""  http://api.ip-10-93-140-37/test/echo/ | cat - | grep "Hello" | wc -l`

echo "The ret_val is :: $ret_val"

echo "======================================================"
if [ $ret_val -ne 0 ]; then
	echo "API Deployment Successful !!!"
else
	echo "API Deployment Failed !!! Please check the log files for more information"
fi
echo "======================================================"

echo
echo "Installation and Validation DONE !!!"
