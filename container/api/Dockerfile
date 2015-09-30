# Docker file for JuliaBox APIs
# Version:34

### MDP FROM julialang/juliaboxpkgdist:v0.3.11
### MDP
FROM julialang/julia:v0.3.11

MAINTAINER Tanmay Mohapatra

RUN ln -fs /opt/julia/bin/julia /usr/bin/julia

# add juser
# create group and user with specific ids if required on systems where the user running juliabox is not the first user
RUN groupadd juser \
    && useradd -m -d /home/juser -s /bin/bash -g juser -G staff juser \
    && echo "export HOME=/home/juser" >> /home/juser/.bashrc \
    && echo "export LD_LIBRARY_PATH=/home/juser:/usr/lib/x86_64-linux-gnu:/usr/lib" >> /home/juser/.bashrc

# add Julia nightly build
## MDP RUN mkdir -p /opt/julia_0.4.0 && \
    ## MDP curl -s -L https://status.julialang.org/download/linux-x86_64 | tar -C /opt/julia_0.4.0 -x -z --strip-components=1 -f -
## MDP RUN ln -fs /opt/julia_0.4.0 /opt/julia_nightly

USER juser
ENV HOME /home/juser
ENV PATH /usr/local/texlive/2014/bin/x86_64-linux:/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin:/opt/julia/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/home/juser
WORKDIR /home/juser

## MDP RUN /opt/julia_0.4.0/bin/julia  -e "try; Pkg.installed(\"JuliaWebAPI\"); catch; Pkg.clone(\"https://github.com/tanmaykm/JuliaWebAPI.jl\"); end"
## MDP RUN /opt/julia_0.3.11/bin/julia -e "try; Pkg.installed(\"JuliaWebAPI\"); catch; Pkg.clone(\"https://github.com/mdpradeep/JuliaWebAPI.jl\"); end"
## MDP check for Pkg.installed was preventing the new package to be pulled from git
## RUN /opt/julia_0.3.11/bin/julia -e "Pkg.clone(\"https://github.com/mdpradeep/JuliaWebAPI.jl\")"
## MDP RUN /opt/julia_0.3.11/bin/julia -e "Pkg.clone(\"https://github.com/JuliaDB/DBI.jl.git\")"
## MDP RUN /opt/julia_0.3.11/bin/julia -e "Pkg.clone(\"DBI\")"
RUN /opt/julia_0.3.11/bin/julia -e "Pkg.clone(\"DataFrames\")" ## required because of other dependencies !!!
## MDP RUN /opt/julia_0.3.11/bin/julia -e "try; Pkg.installed(\"test\"); catch; Pkg.clone(\"test\"); end"

## MDP RUN mkdir -p /home/juser/.julia/v0.3
RUN ls -lrt /home/juser/.julia/v0.3

ADD MySQL* /home/juser/MySQL
## RUN cp -rf /home/juser/MySQL*  /home/juser/.julia/v0.3/
## 
ADD test* /home/juser/test
## RUN cp -rf /home/juser/test*  /home/juser/.julia/v0.3/
## 
ADD DBI* /home/juser/DBI
## RUN cp -rf /home/juser/DBI*  /home/juser/.julia/v0.3/
## 
ADD Budget* /home/juser/Budget
## RUN cp -rf /home/juser/Budget*  /home/juser/.julia/v0.3/
## 
ADD ODBC* /home/juser/ODBC
## RUN cp -rf /home/juser/ODBC*  /home/juser/.julia/v0.3/
## 
ADD JuliaWebAPI /home/juser/JuliaWebAPI

## RUN rm -rf /home/juser/.julia/v0.3/JuliaWebAPI
## RUN /opt/julia_0.3.11/bin/julia -e "Pkg.rm(\"JuliaWebAPI\")" ## Need to do this to get dependencies !!!
## RUN /opt/julia_0.3.11/bin/julia -e "Pkg.clone(\"/home/juser/JuliaWebAPI\")" ## Need to do this to get dependencies !!!
## MDP cloned above RUN cp -r /home/juser/JuliaWebAPI*  /home/juser/.julia/v0.3/

ADD Match* /home/juser/Match
## RUN cp -rf /home/juser/Match*  /home/juser/.julia/v0.3/
## 
ADD Compat* /home/juser/Compat
## RUN cp -rf /home/juser/Compat*  /home/juser/.julia/v0.3/
## 
ADD Debug* /home/juser/Debug
## RUN cp -rf /home/juser/Debug*  /home/juser/.julia/v0.3/
## 
ADD Dates* /home/juser/Dates
## RUN cp -rf /home/juser/Dates*  /home/juser/.julia/v0.3/


ADD libmysqlclient.so* /home/juser/
ADD libodbc.so* /home/juser/
ADD libltdl.so.7* /home/juser/
ADD clonePackages.sh /home/juser/clonePackages.sh

RUN ./clonePackages.sh

RUN mkdir -p /home/juser/logs && chmod 777 /home/juser/logs

VOLUME /home/juser/logs

## MDP RUN cp /home/juser/libmysqlclient.so*  /usr/lib/

ENTRYPOINT ["julia", "-e", "using JuliaWebAPI; using Compat; process();"]
