#!/usr/bin/env bash

rm *.txt

wget -T 30 -t 0 "ftp://ftp.ifremer.fr/ifremer/argo/ar_index_global_prof.txt.gz"
wget -T 30 -t 0 "ftp://ftp.ifremer.fr/ifremer/argo/ar_index_global_traj.txt.gz"

gzip -d ar_index_global_prof.txt.gz
gzip -d ar_index_global_traj.txt.gz

file01="ftp://ftp.ifremer.fr/ifremer/argo/dac/"
file02=" ftp://usgodae.org/pub/outgoing/argo/dac/"

mkdir "./PACIFIC"
mkdir "./PACIFIC/prof"

grep -e"/profiles/D".*".nc,..............,-"{01..40}"....".*",-"{060..140}.*",P," ar_index_global_prof.txt | cut -d "," -f 1 | cut -d "/" -f1-2 | sort | uniq >> info.txt

while IFS= read -r line; do
    wget -T 30 -t 0 -P "./PACIFIC/prof/" "$file01$line/*prof.nc"
done < info.txt



while read p ; do
  tim=$(echo $p | cut -d ' ' -f 1); lon=$(echo $p | cut -d ' ' -f 2); lat=$(echo $p | cut -d ' ' -f 3);
  echo $tim' '$lon' '$lat
  ncks -d time,$tim "daily_temp_2000-2020.nc" "date_"$tim".nc"
  cdo -P 48 remapnn,lon=${lon}_lat=${lat} "date_"$tim".nc" "profile_"$tim".nc"
  rm "date_"$tim".nc"
done < traj.txt

while read p ; do
  tim=$(echo $p | cut -d ' ' -f 1); lon=$(echo $p | cut -d ' ' -f 2); lat=$(echo $p | cut -d ' ' -f 3);
  echo $tim' '$lon' '$lat
  ncks -d time,$tim "daily_temp_2000-2020.nc" "date_"$tim".nc"
  cdo -P 48 remapnn,lon=${lon}_lat=${lat} "date_"$tim".nc" "profile_"$tim".nc"
  rm "date_"$tim".nc"
done < traj.txt
