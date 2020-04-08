#!/bin/bash

max_sta=64
NumSta=50
NRawGroups=1
NumSlot=1
beaconinterval=102400
pageSliceLen=1

pageSliceCount=$(( NumSta/max_sta ))
echo $pageSliceCount
mod=$(( NumSta%max_sta ))
echo $mod

if [ $mod != 0 ]
then
  pageSliceCount=$(( $pageSliceCount + 1 ))
fi

echo $pageSliceCount
