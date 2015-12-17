#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage: mk_user_home.sh <data_location>"
    exit 1
fi

DATA_LOC=$1
JUSER_HOME=/tmp/juser
PKG_DIR=/tmp/jpkg
PKG_DIR_CUSTOM=/tmp/jpkg_custom

### TODO: Move the packages to a better location than home !
LOCAL_PACKAGE_FOLDER=/home/vagrant/JuliaBox/container/api

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#SUDO_JUSER="sudo -u#1000 -g#1000"
SUDO_JUSER="sudo"

function error_exit {
	echo "$1" 1>&2
	exit 1
}

sudo rm -rf ${JUSER_HOME}
sudo rm -rf ${PKG_DIR}
sudo rm -rf ${PKG_DIR_CUSTOM}
mkdir -p ${JUSER_HOME}
mkdir -p ${PKG_DIR}
mkdir -p ${PKG_DIR_CUSTOM}
mkdir -p ${JUSER_HOME}/.juliabox
mkdir -p ${PKG_DIR}/jimg/stable
mkdir -p ${PKG_DIR}/jimg/nightly

cp ${DIR}/setup_julia.sh ${JUSER_HOME}
cp ${DIR}/jimg.jl ${JUSER_HOME}
cp ${DIR}/mkjimg.jl ${JUSER_HOME}

### MDP 

LOCAL_PACKAGES="${LOCAL_PACKAGE_FOLDER}/DataFrames \
${LOCAL_PACKAGE_FOLDER}/Compat \
${LOCAL_PACKAGE_FOLDER}/Debug \
${LOCAL_PACKAGE_FOLDER}/DBI \
${LOCAL_PACKAGE_FOLDER}/Dates \
${LOCAL_PACKAGE_FOLDER}/ODBC \
${LOCAL_PACKAGE_FOLDER}/Match \
${LOCAL_PACKAGE_FOLDER}/JuliaWebAPI \
${LOCAL_PACKAGE_FOLDER}/MySQL"
## /home/vagrant/MySQL"
## /home/vagrant/JuliaBox/container/api/Budget"
## /home/vagrant/JustDial/Budget"
## /home/vagrant/JustDial/CalculateBudget"

for pkg in ${LOCAL_PACKAGES}
do
    echo ""
    echo "Copying local package $pkg to Julia stable"
    cp -rf $pkg ${PKG_DIR_CUSTOM}
done
### MDP

sudo chown -R 1000:1000 ${JUSER_HOME}
sudo chown -R 1000:1000 ${PKG_DIR}
## MDP sudo chown -R juser:juser ${JUSER_HOME}
## MDP sudo chown -R juser:juser ${PKG_DIR}
docker run -i -v ${JUSER_HOME}:/home/juser -v ${PKG_DIR_CUSTOM}:/opt/julia_packages_custom -v ${PKG_DIR}:/opt/julia_packages -e "JULIA_PKGDIR=/opt/julia_packages/.julia" --entrypoint="/home/juser/setup_julia.sh" juliabox/juliabox:latest || error_exit "Could not run juliabox image"
# MDP docker run -i -v ${JUSER_HOME}:/home/juser -v ${PKG_DIR}:/opt/julia_packages -e "JULIA_PKGDIR=/opt/julia_packages/.julia" --user=root --workdir=/home/juser --entrypoint="julia" juliabox/juliabox:latest mkjimg.jl || error_exit "Could not run juliabox image"

## retVal = $?

## echo " =========================================== The ret val is ${retVal} ================================================= "

## precompilation fails mysteriously sometimes. retry a couple of times to rule out spurious errors
#n=0
#until [ $n -ge 3 ]
#do
#    docker run -i -v ${JUSER_HOME}:/home/juser -v ${PKG_DIR}:/opt/julia_packages -e "JULIA_PKGDIR=/opt/julia_packages/.julia" --user=root --workdir=/home/juser --entrypoint="julia" juliabox/juliabox:latest mkjimg.jl && break
#    echo "Building image failed. Will retry."
#    n=$[$n+1]
#    sleep 10
#done
#
#if [ $n -ge 3 ]
#then
#    error_exit "Could not run juliabox image"
#fi

sudo chown -R 1000:1000 ${JUSER_HOME}
sudo chown -R 1000:1000 ${PKG_DIR}
## MDP sudo chown -R juser:juser ${JUSER_HOME}
## MDP sudo chown -R juser:juser ${PKG_DIR}

sudo mkdir -p ${JUSER_HOME}/logs ### MDP
sudo chown -R 1000:1000 ${JUSER_HOME}/logs ### MDP
sudo chmod -R 777 ${JUSER_HOME}/logs ### MDP

## MDP ${SUDO_JUSER} rm ${JUSER_HOME}/setup_julia.sh ${JUSER_HOME}/build_sysimg.jl ${JUSER_HOME}/jimg.jl ${JUSER_HOME}/mkjimg.jl
${SUDO_JUSER} rm ${JUSER_HOME}/setup_julia.sh ${JUSER_HOME}/jimg.jl ${JUSER_HOME}/mkjimg.jl

## MDP
${SUDO_JUSER} mkdir -p ${JUSER_HOME}/.ipython/profile_default/static/custom/
## MDP
${SUDO_JUSER} cp ${DIR}/IJulia/ipython_notebook_config.py ${JUSER_HOME}/.ipython/profile_default/ipython_notebook_config.py
${SUDO_JUSER} cp ${DIR}/IJulia/custom.css ${JUSER_HOME}/.ipython/profile_default/static/custom/custom.css
${SUDO_JUSER} cp ${DIR}/IJulia/custom.js ${JUSER_HOME}/.ipython/profile_default/static/custom/custom.js

# install RISE (slideshow plugin)
#${SUDO_JUSER} cd /home/juser && git clone https://github.com/damianavila/RISE.git && cd RISE && git checkout -b 3.x 3.x && python setup.py install && cd .. && rm -rf RISE

${SUDO_JUSER} cp -R ${DIR}/IJulia/tornado ${JUSER_HOME}/.juliabox/tornado
${SUDO_JUSER} cp ${DIR}/IJulia/supervisord.conf ${JUSER_HOME}/.juliabox/supervisord.conf
${SUDO_JUSER} cp -R ${DIR}/IJulia/tutorial ${JUSER_HOME}/.juliabox/tutorial

sudo rm ${DATA_LOC}/julia_packages.tar.gz
sudo tar -czvf ${DATA_LOC}/julia_packages.tar.gz -C ${PKG_DIR} .

sudo rm ${DATA_LOC}/user_home.tar.gz
sudo tar -czvf ${DATA_LOC}/user_home.tar.gz -C ${JUSER_HOME} .

sudo rm -rf ${JUSER_HOME}
sudo rm -rf ${PKG_DIR}
for id in `docker ps -a | grep Exited | cut -d" " -f1 | grep -v CONTAINER`
do
    echo "removing $id..."
    docker rm $id
done
