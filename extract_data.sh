#!/usr/bin/env bash

while read p ; do
  tim=$(echo $p | cut -d ' ' -f 1); lon=$(echo $p | cut -d ' ' -f 2); lat=$(echo $p | cut -d ' ' -f 3); idx=$(echo $p | cut -d ' ' -f 4);
  echo $tim' '$lon' '$lat' '$idx 
  cdo -P 24 -remapnn,lon=${lon}_lat=${lat} -seldate,$tim "/data/datos/MERCATOR/glorys_12v1/glorys12v1_"$tim".nc" "profile_"$tim"_"$idx".nc"
#  cdo -P 24 -remapnn,lon=${lon}_lat=${lat} -seldate,$tim "data.nc" "profile_"$tim"_"$idx".nc"
done < traj.txt

#cdo -P 24 mergetime profile_*.nc 6901504_Sprof_cow4.nc
cdo -P 24 mergetime profile_*.nc 6901504_Sprof_glorys12v1.nc

rm profile_*.nc



