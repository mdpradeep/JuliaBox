#!/bin/bash

julia -e 'Pkg.init()'


CUSTOM_LOCAL_PACKAGE_FOLDER=/opt/julia_packages_custom

# Install packages for Julia stable
DEFAULT_PACKAGES="IJulia" # Gadfly PyPlot SIUnits DataStructures HDF5 MAT \
#Iterators NumericExtensions SymPy Interact Roots \
#DataFrames RDatasets Distributions SVM Clustering GLM \
#Optim JuMP GLPKMathProgInterface Clp NLopt Ipopt \
#Cairo GraphViz \
#Images ImageView WAV ODE Sundials LinearLeastSquares \
#BayesNets PGFPlots GraphLayout \
#Stan Patchwork Quandl Lazy QuantEcon MixedModels Escher"

for pkg in ${DEFAULT_PACKAGES}
do
    echo ""
    echo "Adding default package $pkg to Julia stable"
    julia -e "Pkg.add(\"$pkg\")"
done


INTERNAL_PACKAGES="https://github.com/tanmaykm/JuliaBoxUtils.jl.git"
# \
## https://github.com/JuliaDB/DBI.jl.git \
## https://github.com/mdpradeep/JuliaWebAPI.jl.git \
## https://github.com/shashi/Homework.jl.git"

for pkg in ${INTERNAL_PACKAGES}
do
    echo ""
    echo "Adding internal package $pkg to Julia stable"
    julia -e "Pkg.clone(\"$pkg\")"
done

if [[ $DEFAULT_PACKAGES == *" Interact "* ]]
then
    echo "Checking out Interact package for IPython 3 compatibility"
    julia -e "Pkg.checkout(\"Interact\")"
fi

### MDP 
## echo "Listing source and target ...."
## ls -l /opt/julia_packages_custom/


LOCAL_PACKAGES="${CUSTOM_LOCAL_PACKAGE_FOLDER}/DataFrames \
${CUSTOM_LOCAL_PACKAGE_FOLDER}/DBI \
${CUSTOM_LOCAL_PACKAGE_FOLDER}/Debug \
${CUSTOM_LOCAL_PACKAGE_FOLDER}/Match \
${CUSTOM_LOCAL_PACKAGE_FOLDER}/Dates \
${CUSTOM_LOCAL_PACKAGE_FOLDER}/ODBC \
${CUSTOM_LOCAL_PACKAGE_FOLDER}/JuliaWebAPI \
${CUSTOM_LOCAL_PACKAGE_FOLDER}/MySQL"
# \
## /opt/julia_packages_custom/Budget"
## Already part of IJulia ... /opt/julia_packages_custom/Compat \

for pkg in ${LOCAL_PACKAGES}
do
    echo ""
    echo "Copying local package $pkg to Julia stable"
    ## cp -rf $pkg /home/juser/.julia/v0.3.11/
    julia -e "Pkg.clone(\"$pkg\")"
done

echo "Inspecting julia package status !!!"
julia -e "Pkg.status()"
echo "Inspecting julia package status done !!!"

### MDP
## exit

echo ""
echo "Creating Julia stable package list..."
julia -e 'println("JULIA_HOME: $JULIA_HOME\n"); versioninfo(); println(""); Pkg.status()' > /opt/julia_packages/stable_packages.txt 2>&1
## MDP julia -e 'println("JULIA_HOME: $JULIA_HOME\n"); versioninfo(); println(""); Pkg.status()' > /opt/julia_packages/stable_packages.txt
#echo ""
#echo "Running package tests..."
#julia -e "Pkg.test()" > /opt/julia_packages/packages_test_result.txt


## MDP /opt/julia_nightly/bin/julia -e 'Pkg.init()'

# Install packages for Julia nightly
## MDP JULIA_NIGHTLY_DEFAULT_PACKAGES="IJulia"
## MDP
JULIA_NIGHTLY_DEFAULT_PACKAGES=""

for pkg in ${JULIA_NIGHTLY_DEFAULT_PACKAGES}
do
    echo ""
    echo "Adding default package $pkg to Julia nightly"
    /opt/julia_nightly/bin/julia -e "Pkg.add(\"$pkg\")"
done

## MDP JULIA_NIGHTLY_INTERNAL_PACKAGES="https://github.com/tanmaykm/JuliaBoxUtils.jl.git \
## MDP https://github.com/tanmaykm/JuliaWebAPI.jl.git \
## MDP https://github.com/shashi/Homework.jl.git"
JULIA_NIGHTLY_INTERNAL_PACKAGES=""

for pkg in ${JULIA_NIGHTLY_INTERNAL_PACKAGES}
do
    echo ""
    echo "Adding internal package $pkg to Julia nightly"
    /opt/julia_nightly/bin/julia -e "Pkg.clone(\"$pkg\")"
done

## MDP if [[ $JULIA_NIGHTLY_DEFAULT_PACKAGES == *" Interact "* ]]
## MDP then
    ## MDP echo "Checking out Interact package for IPython 3 compatibility"
    ## MDP /opt/julia_nightly/bin/julia -e "Pkg.checkout(\"Interact\")"
## MDP fi

## MDP
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/juser

echo ""
echo "Creating Julia nightly package list..."
## MDP /opt/julia_nightly/bin/julia -e 'println("JULIA_HOME: $JULIA_HOME\n"); versioninfo(); println(""); Pkg.status()' > /opt/julia_packages/nightly_packages.txt
