#!/bin/bash

JUSER_HOME=/tmp/juser
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#SUDO_JUSER="sudo -u#1000 -g#1000"
SUDO_JUSER=""

function error_exit {
	echo "$1" 1>&2
	exit 1
}

sudo rm -rf ${JUSER_HOME}
mkdir -p ${JUSER_HOME}
mkdir -p ${JUSER_HOME}/.juliabox
mkdir -p ${JUSER_HOME}/.juliabox/jimg

cp ${DIR}/api/setup_julia.sh ${JUSER_HOME}
cp ${DIR}/build_sysimg.jl ${JUSER_HOME}
cp ${DIR}/jimg.jl ${JUSER_HOME}
cp ${DIR}/mkjimg.jl ${JUSER_HOME}

sudo chown -R 1000:1000 ${JUSER_HOME}
sudo docker run -i -v ${JUSER_HOME}:/home/juser --entrypoint="/home/juser/setup_julia.sh" juliabox/juliabox:latest || error_exit "Could not run juliabox image"
sudo docker run -i -v ${JUSER_HOME}:/home/juser --user=root --workdir=/home/juser --entrypoint="julia" juliabox/juliabox:latest mkjimg.jl || error_exit "Could not run juliabox image"
sudo chown -R 1000:1000 ${JUSER_HOME}
${SUDO_JUSER} rm ${JUSER_HOME}/setup_julia.sh ${JUSER_HOME}/build_sysimg.jl ${JUSER_HOME}/jimg.jl ${JUSER_HOME}/mkjimg.jl

# create julia kernels
${SUDO_JUSER} mkdir -p ${JUSER_HOME}/.ipython/kernels/julia\ 0.3
${SUDO_JUSER} cat > ${JUSER_HOME}/.ipython/kernels/julia\ 0.3/kernel.json <<EOF
{
        "argv": ["/usr/bin/julia", "-F", "/home/juser/.julia/v0.3/IJulia/src/kernel.jl", "{connection_file}"],
        "display_name": "Julia 0.3.6",
        "language": "julia"
}
EOF

#${SUDO_JUSER} mkdir -p ${JUSER_HOME}/.ipython/kernels/jboxjulia
#${SUDO_JUSER} cat > ${JUSER_HOME}/.ipython/kernels/jboxjulia/kernel.json <<EOF
#{
#        "argv": ["/usr/bin/julia", "-J", "/home/juser/.juliabox/jimg/sys.ji", "-F", "/home/juser/.julia/v0.3/IJulia/src/kernel.jl", "{connection_file}"],
#        "codemirror_mode": "julia",
#        "display_name": "Julia(JuliaBox)",
#        "language": "julia"
#}
#EOF

for prof in "julia" "jboxjulia"
do
    echo "c.NotebookApp.open_browser = False" | ${SUDO_JUSER} tee --append ${JUSER_HOME}/.ipython/profile_${prof}/ipython_notebook_config.py
    echo "c.NotebookApp.ip = \"*\"" | ${SUDO_JUSER} tee --append ${JUSER_HOME}/.ipython/profile_${prof}/ipython_notebook_config.py
    echo "c.NotebookApp.allow_origin = \"*\"" | ${SUDO_JUSER} tee --append ${JUSER_HOME}/.ipython/profile_${prof}/ipython_notebook_config.py
    ${SUDO_JUSER} cp ${DIR}/IJulia/custom.css ${JUSER_HOME}/.ipython/profile_${prof}/static/custom/custom.css
    ${SUDO_JUSER} cp ${DIR}/IJulia/custom.js ${JUSER_HOME}/.ipython/profile_${prof}/static/custom/custom.js
done

${SUDO_JUSER} cp -R ${DIR}/IJulia/tornado ${JUSER_HOME}/.juliabox/tornado
${SUDO_JUSER} cp ${DIR}/IJulia/supervisord.conf ${JUSER_HOME}/.juliabox/supervisord.conf
${SUDO_JUSER} cp -R ${DIR}/IJulia/tutorial ${JUSER_HOME}/.juliabox/tutorial

sudo rm ~/user_home.tar.gz
sudo tar -czvf ~/user_home.tar.gz -C ${JUSER_HOME} .
sudo rm -rf ${JUSER_HOME}
for id in `docker ps -a | grep Exited | cut -d" " -f1 | grep -v CONTAINER`
do
    echo "removing $id..."
    docker rm $id
done