#!/bin/bash

rawG=$1
NumSlot=$2
distance=200

numStaArray=(127 255 511 1023 2047)
#numStaArray=(1023)
echo "Starting simulation"

for NumSta in ${numStaArray[@]}
  do
     case "$NumSta" in
     127) pageSliceLen=1
         time=120
     ;;
     255) pageSliceLen=2
         time=120
     ;;
     511) pageSliceLen=4
         time=120
     ;;
     1023) pageSliceLen=4
          time=120
     ;;
     2047) pageSliceLen=4
          time=120
     ;;
     esac
     echo "Parameters set $NumSta $rawG $NumSlot $pageSliceLen $time $distance"
     ./simulation_script.sh $NumSta $rawG $NumSlot $pageSliceLen $time $distance
 done
