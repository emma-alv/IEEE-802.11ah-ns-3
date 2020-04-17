#!/bin/bash

echo "Starting simulation"
tree
for NumSta in {100..200..100}
  do
     echo "Number of stations $NumSta"
     ./simulation_script.sh $NumSta
 done

echo "Sync with S3 bucket"
aws s3 sync ./results s3://802.11ah