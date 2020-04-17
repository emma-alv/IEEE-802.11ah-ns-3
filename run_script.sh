#!/bin/bash

for NumSta in {100..200..100}
  do
     echo "Number of stations $NumSta"
     ./simulation_script.sh $NumSta
 done
