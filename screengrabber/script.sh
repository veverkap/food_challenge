#!/bin/bash
data_dir="$(dirname $(dirname $(realpath $0)) )/images"
echo "SCRAPING TO DIRECTORY: $data_dir"
echo "GETTING UPDATED URL"
url=$(curl -s https://v.angelcam.com/iframe\?v\=9klzdgn2y4\&autoplay\=1 | grep 'source: ' | grep -Eo 'https://[^/"]+.*' | cut -d \' -f 1)
echo "FOUND $url"
echo "GRABBING SCREENSHOT"

filename=$data_dir/bigtexan_$(date +%s).jpg
ffmpeg -hide_banner -loglevel panic -i $url -frames:v 1 $filename
echo "GRABBED $filename"
