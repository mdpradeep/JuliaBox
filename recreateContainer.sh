#!/bin/bash
./scripts/run/stop.sh
./scripts/run/clean.sh
docker rmi juliabox/juliaboxapi  ## to be removed later
./scripts/run/docker_rmall.sh

echo "Removing julia_packages folder"
cd /jboxengine/data/packages/
mv -f julia_packages julia_packages_BAK
cd -

sudo ./scripts/install/img_create.sh cont build
sudo ./scripts/install/img_create.sh home /jboxengine/data
./scripts/install/img_create.sh jbox 

echo "Done"
