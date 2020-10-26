#!/bin/bash

rawG=$1
NumSlot=$2

#numStaArray=(127 255 511 1023 2047)
numStaArray=(1023 2047)
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
         time=150
     ;;
     1023) pageSliceLen=4
          time=150
     ;;
     2047) pageSliceLen=4
          time=190
     ;;
     esac
     echo "Parameters set $NumSta $rawG $NumSlot $pageSliceLen $time"
     ./simulation_script.sh $NumSta $rawG $NumSlot $pageSliceLen $time
 done
