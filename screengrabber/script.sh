#!/bin/bash
data_dir="$(dirname $(dirname $(realpath $0)) )/images"
echo "SCRAPING TO DIRECTORY: $data_dir"

filename=$data_dir/bigtexan_$(date +%s).jpg
ffmpeg -hide_banner -loglevel panic -i $1 -frames:v 1 $filename
echo "GRABBED $filename"


b2 sync --keepDays 3 --replaceNewer ./videos b2://meatsweats/videos
b2 sync --allowEmptySource --keepDays 3 --replaceNewer ./images/detected b2://meatsweats/images/detected
b2 sync --allowEmptySource --keepDays 3 --replaceNewer ./json b2://meatsweats/json
b2 sync --allowEmptySource --keepDays 3 --replaceNewer ./images/person b2://meatsweats/images/person
b2 sync --allowEmptySource --keepDays 3 --replaceNewer ./images/processed b2://meatsweats/images/processed
