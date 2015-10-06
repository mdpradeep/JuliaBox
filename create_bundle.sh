#!/bin/sh


##TODO :  Check if the at bundle exists. If so, either ask to overwrite or move it to a BAK !

## Tar up all the required images and components
## tar cvf JuliaDeploymentBundle.tar JuliaDeployment JuliaDeploymentImages jboxengine install_julia_deployment.sh
tar cvf JuliaDeploymentBundle.tar JuliaDeployment JuliaDeploymentImages jboxengine 
