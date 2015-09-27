#!/bin/sh

cp -rf /home/juser/Match*  /home/juser/.julia/v0.3/
cp -rf /home/juser/Compat*  /home/juser/.julia/v0.3/
cp -rf /home/juser/Debug*  /home/juser/.julia/v0.3/
cp -rf /home/juser/Dates*  /home/juser/.julia/v0.3/

cp -rf /home/juser/MySQL*  /home/juser/.julia/v0.3/
cp -rf /home/juser/jd*  /home/juser/.julia/v0.3/
cp -rf /home/juser/DBI*  /home/juser/.julia/v0.3/
cp -rf /home/juser/Budget*  /home/juser/.julia/v0.3/

## RUN rm -rf /home/juser/.julia/v0.3/JuliaWebAPI
## RUN /opt/julia_0.3.11/bin/julia -e "Pkg.rm(\"JuliaWebAPI\")" ## Need to do this to get dependencies !!!
/opt/julia_0.3.11/bin/julia -e "Pkg.clone(\"/home/juser/JuliaWebAPI\")" ## Need to do this to get dependencies !!!
/opt/julia_0.3.11/bin/julia -e "Pkg.clone(\"/home/juser/ODBC\")" ## Need to do this to get dependencies !!!

### MDP bad hack to work around sticky cache !!!! :( 
cp -rf /home/juser/JuliaWebAPI/* /home/juser/.julia/v0.3/JuliaWebAPI/
cp -rf /home/juser/ODBC*  /home/juser/.julia/v0.3/

export LD_LIBRARY_PATH=/home/juser:/usr/lib/x86_64-linux-gnu:/usr/lib
echo $LD_LIBRARY_PATH
## cp /home/juser/*.so* /usr/lib/
echo $?

echo "Cloning done !!!"
