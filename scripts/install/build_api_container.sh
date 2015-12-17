#! /usr/bin/env bash
# Build or pull JuliaBox docker images

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
JBOX_DIR=`readlink -e ${DIR}/../..`

function build_containers {
    ## for imgspec in juliabox,interactive juliaboxapi,api
    for imgspec in juliaboxapi,api
    do
        IFS=","
        set ${imgspec}
        IMGTAG="juliabox/$1"
        DOCKERDIR=${JBOX_DIR}/container/$2/
        IMGVER=$(grep "^# Version:" ${DOCKERDIR}/Dockerfile | cut -d":" -f2)
        echo ""
        echo "======================================================"
        echo "Building container ${IMGTAG}:${IMGVER} from ${DOCKERDIR} ..."
        echo "======================================================"

	## MDPecho "building with no-cache !!!"
       	## MDPdocker build --no-cache  -t ${IMGTAG}:${IMGVER} -f ${DOCKERDIR}/Dockerfile ${DOCKERDIR}
        docker build -t ${IMGTAG}:${IMGVER} -f ${DOCKERDIR}/Dockerfile ${DOCKERDIR}
        docker tag -f ${IMGTAG}:${IMGVER} ${IMGTAG}:latest
    done
}


./scripts/run/stop.sh
./scripts/run/clean.sh
./scripts/run/docker_rmall.sh
docker rmi juliabox/juliaboxapi:34
docker rmi juliabox/juliaboxapi
build_containers 

echo
echo "DONE!"
