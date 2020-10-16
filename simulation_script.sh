#!/bin/bash

user=$( whoami )

path_folder="/home/${user}/IEEE-802.11ah-ns-3"

simType="bySlotN"
NumSta=$1
NRawGroups=4
NumSlot=2
beaconinterval=102400
pageSliceLen=$2
bandWidth=1
distance=200
time=120
payloadSize=100
DataMode="MCS1_0"
TrafficType="udpecho"
#tcpipcamera, udpecho
NOW=$(date +"%F_%H_%M_%S")

max_sta=$(( pageSliceLen * 64 ))

pageSliceCount=$(( NumSta/max_sta ))
mod=$(( NumSta%max_sta ))

if [ $mod != 0 ]
then
  pageSliceCount=$(( pageSliceCount + 1 ))
fi

if [ $NumSta -le $max_sta ]
then
  pageSliceCount=0
fi

echo $pageSliceCount

RAWConfigPath="$path_folder/OptimalRawGroup/RawConfig-$NumSta-$NRawGroups-$NumSlot-$beaconinterval-$pageSliceCount-$pageSliceLen.txt"

$path_folder/waf --run "RAW-generate --NRawSta=$NumSta --NGroup=$NRawGroups --NumSlot=$NumSlot --RAWConfigPath=$RAWConfigPath --beaconinterval=$beaconinterval \
--pageSliceCount=$pageSliceCount --pageSliceLen=$pageSliceLen"

echo $RAWConfigPath


if [ ! -d $path_folder/results/ ]
then
    mkdir $path_folder/results/
fi

if [ ! -d $path_folder/results/logs ]
then
    mkdir $path_folder/results/logs
fi

if [ ! -d $path_folder/results/$simType ]
then
    mkdir $path_folder/results/$simType
fi

if [ ! -d $path_folder/results/$simType/$DataMode ]
then
    mkdir $path_folder/results/$simType/$DataMode
fi

if [ ! -d $path_folder/results/$simType/$DataMode/$TrafficType ]
then
    mkdir $path_folder/results/$simType/$DataMode/$TrafficType
fi

if [ ! -d $path_folder/results/$simType/$DataMode/$TrafficType/RAW_G_$NRawGroups ]
then
    mkdir $path_folder/results/$simType/$DataMode/$TrafficType/RAW_G_$NRawGroups
fi

if [ ! -d $path_folder/results/$simType/$DataMode/$TrafficType/RAW_G_$NRawGroups/RAW_S_$NumSlot ]
then
    mkdir $path_folder/results/$simType/$DataMode/$TrafficType/RAW_G_$NRawGroups/RAW_S_$NumSlot
fi

date


Name="$distance-m-$NumSta-sta-$time-time"

$path_folder/waf --run "test --seed=1 --simulationTime=$time --payloadSize=$payloadSize --Nsta=$NumSta --pagePeriod=$pageSliceCount --pageSliceLength=$pageSliceLen --pageSliceCount=$pageSliceCount \
--NRawSlotNum=$NumSlot --NGroup=$NRawGroups --rho=$distance --bandWidth=$bandWidth --DataMode=$DataMode --TrafficType=$TrafficType --RAWConfigFile=$RAWConfigPath --Name=$Name"

echo "RAW PATH = ./OptimalRawGroup/RawConfig-$NumSta-$NRawGroups-$NumSlot-$beaconinterval-$pageSliceCount-$pageSliceLen.txt" >> $path_folder/results/logs/simlog_$NOW.txt
echo "./results/logs/simlog_$NOW.txt"
echo "Simulation Done"

date

lastSimulation=$(ls -trh | grep $TrafficType | tail -n 1)

if [[ $lastSimulation == *"$TrafficType"* ]]
then
    mv $lastSimulation $path_folder/results/$simType/$DataMode/$TrafficType/RAW_G_$NRawGroups/RAW_S_$NumSlot/$Name.nss
    head -n 20 $path_folder/simulation_script.sh >> $path_folder/results/$simType/$DataMode/$TrafficType/RAW_G_$NRawGroups/RAW_S_$NumSlot/$Name.conf
    echo $Name
else
    echo "Error copying results"
    exit 1
fi

