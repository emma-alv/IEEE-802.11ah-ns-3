#!/bin/bash

max_sta=64
NumSta=$1
NRawGroups=1
NumSlot=1
beaconinterval=102400
pageSliceLen=4
bandWidth=1
distance=200
time=120
payloadSize=100
DataMode="MCS1_0"
TrafficType="udpecho"
#tcpipcamera, udpecho
NOW=$(date +"%F")

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

if [ ! -d ./results/ ]
then
    mkdir ./results/
fi

if [ ! -d ./results/$DataMode ]
then
    mkdir ./results/$DataMode
fi

if [ ! -d ./results/$DataMode/$TrafficType ]
then
    mkdir ./results/$DataMode/$TrafficType
fi

if [ ! -d ./results/$DataMode/$TrafficType/RAW_G_$NRawGroups ]
then
    mkdir ./results/$DataMode/$TrafficType/RAW_G_$NRawGroups
fi

if [ ! -d ./results/$DataMode/$TrafficType/RAW_G_$NRawGroups/RAW_S_$NumSlot ]
then
    mkdir ./results/$DataMode/$TrafficType/RAW_G_$NRawGroups/RAW_S_$NumSlot
fi




Name="$distance-m-$NumSta-sta-$time-time"

./waf --run "test --seed=1 --simulationTime=$time --payloadSize=$payloadSize --Nsta=$NumSta --pagePeriod=$pageSliceCount --pageSliceLength=$pageSliceLen --pageSliceCount=$pageSliceCount \
--NRawSlotNum=$NumSlot --NGroup=$NRawGroups --rho=$distance --bandWidth=$bandWidth --DataMode=$DataMode --TrafficType=$TrafficType --RAWConfigFile=$RAWConfigPath --Name=$Name" > ./results/$DataMode/$TrafficType/RAW_G_$NRawGroups/RAW_S_$NumSlot/simlog_$NOW.txt 2>&1

echo "./results/$DataMode/$TrafficType/RAW_G_$NRawGroups/RAW_S_$NumSlot/simlog_$NOW.txt"
echo "Simulation Done"

lastSimulation=$(ls -trh | tail -n 1)

if [[ $lastSimulation == *"$TrafficType"* ]]
then
    mv $lastSimulation ./results/$DataMode/$TrafficType/RAW_G_$NRawGroups/RAW_S_$NumSlot/$Name.nss
    echo $Name
else
    echo "Error copying results"
    exit 1
fi

