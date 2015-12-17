#!/bin/bash
./scripts/run/stop.sh
./scripts/run/clean.sh
docker rmi juliabox/juliaboxapi  ## to be removed later
./scripts/run/docker_rmall.sh

echo "Removing jboxengine folder"
sudo mv -f /jboxengine /jboxengine_BAK

## MDP ./scripts/install/sys_install.sh
sudo mkdir -p /jboxengine/conf /jboxengine/data/db /jboxengine/data/disks/host
sudo chown -R $USER: /jboxengine
cp ~/JuliaBox/jbox.user.template /jboxengine/conf/jbox.user
./scripts/install/jbox_configure.sh
sudo docker pull julialang/julia:v0.4.1
sudo docker pull ubuntu:14.04
sudo docker build -t julialang/julia:v0.4.1 ~/JuliaDockerImages/base/v0.4

sudo ./scripts/install/img_create.sh cont build
sudo ./scripts/install/img_create.sh home /jboxengine/data
sudo ./scripts/install/img_create.sh jbox 

./scripts/install/create_tables_sqlite.py /jboxengine/data/db/juliabox.db
echo "Done"
