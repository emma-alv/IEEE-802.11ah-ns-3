#!/bin/bash

max_sta=64
NumSta=100
NRawGroups=1
NumSlot=1
beaconinterval=102400
pageSliceLen=1
bandWidth=1
distance=200
time=180
DataMode="MCS1_0"

pageSliceCount=$(( NumSta/max_sta ))
mod=$(( NumSta%max_sta ))

if [ $mod != 0 ]
then
  pageSliceCount=$(( pageSliceCount + 1 ))
fi

echo $pageSliceCount

RAWConfigPath="./OptimalRawGroup/RawConfig-$NumSta-$NRawGroups-$NumSlot-$beaconinterval-$pageSliceCount-$pageSliceLen.txt"

./waf --run "RAW-generate --NRawSta=$NumSta --NGroup=$NRawGroups --NumSlot=$NumSlot --RAWConfigPath=$RAWConfigPath --beaconinterval=$beaconinterval \
--pageSliceCount=$pageSliceCount --pageSliceLen=$pageSliceLen"

echo $RAWConfigPath

Name="$bandWidth-MHz-$distance-m-$NumSta-sta-$time-time-$DataMode"

./waf --run "test --seed=1 --simulationTime=$time --payloadSize=60 --Nsta=$NumSta --pagePeriod=$pageSliceCount --pageSliceLength=1 --pageSliceCount=$pageSliceCount \
--NRawSlotNum=$NumSlot --rho=$distance --bandWidth=$bandWidth --DataMode=$DataMode --RAWConfigFile=$RAWConfigPath --Name=$Name"

echo "Simulation Done"

lastSimulation=$(ls -trh | tail -n 1)
mv $lastSimulation ./results/$Name.nss

echo $Name
