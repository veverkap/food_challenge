#!/bin/bash
data_dir="$(dirname $(dirname $(realpath $0)) )/images"
echo "SCRAPING TO DIRECTORY: $data_dir"

filename=$data_dir/bigtexan_$(date +%s).jpg
ffmpeg -hide_banner -loglevel panic -i $1 -frames:v 1 $filename
echo "GRABBED $filename"
