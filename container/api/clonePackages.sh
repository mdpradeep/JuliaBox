#!/bin/sh

## MDP VER=v0.3
## MDP FULL_VER=v0.3.11
VER=v0.4
FULL_VER=v0.4.1

cp -rf /home/juser/Match*  /home/juser/.julia/${VER}/
cp -rf /home/juser/Compat*  /home/juser/.julia/${VER}/
cp -rf /home/juser/Debug*  /home/juser/.julia/${VER}/
cp -rf /home/juser/Dates*  /home/juser/.julia/${VER}/

cp -rf /home/juser/MySQL*  /home/juser/.julia/${VER}/
cp -rf /home/juser/test*  /home/juser/.julia/${VER}/
cp -rf /home/juser/DBI*  /home/juser/.julia/${VER}/
cp -rf /home/juser/Budget*  /home/juser/.julia/${VER}/
cp -rf /home/juser/Lexicon*  /home/juser/.julia/${VER}/

## RUN rm -rf /home/juser/.julia/v0.3/JuliaWebAPI
## RUN /opt/julia_0.3.11/bin/julia -e "Pkg.rm(\"JuliaWebAPI\")" ## Need to do this to get dependencies !!!
## MDP /opt/julia-${FULL_VER}/bin/julia -e "Pkg.clone(\"/home/juser/JuliaWebAPI\")" ## Need to do this to get dependencies !!!
## MDP /opt/julia-${FULL_VER}/bin/julia -e "Pkg.clone(\"/home/juser/ODBC\")" ## Need to do this to get dependencies !!!
## /opt/julia/bin/julia -e "Pkg.clone(\"/home/juser/JuliaWebAPI\")" ## Need to do this to get dependencies !!!
## /opt/julia/bin/julia -e "Pkg.clone(\"/home/juser/ODBC\")" ## Need to do this to get dependencies !!!

### MDP bad hack to work around sticky cache !!!! :( 
cp -rf /home/juser/JuliaWebAPI/* /home/juser/.julia/${VER}/JuliaWebAPI/
cp -rf /home/juser/ODBC*  /home/juser/.julia/${VER}/

export LD_LIBRARY_PATH=/home/juser:/usr/lib/x86_64-linux-gnu:/usr/lib
## echo $LD_LIBRARY_PATH
## cp /home/juser/*.so* /usr/lib/
## echo $?

echo "Cloning done !!!"
