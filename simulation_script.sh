#!/bin/bash

bandWidth=1
distance=500
Nsta=190

Name="$bandWidth-MHz-$distance-m-$Nsta"
visualizerPath="$HOME/ahVisualizer/forwardsocketdata/simulations"

./waf --run "test --seed=1 --simulationTime=60 --payloadSize=60 --Nsta=$Nsta --pagePeriod=3 --pageSliceLength=1 --pageSliceCount=3 --rho=$distance --bandWidth=$bandWidth --Name=$Name"

lastSimulation=$(ls -trh | tail -n 1)

mv $lastSimulation $visualizerPath/$Name.nss
