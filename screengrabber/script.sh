#!/bin/bash
data_dir="$(dirname $(dirname $(realpath $0)) )/images"

echo "SCRAPING TO DIRECTORY: $data_dir"

echo "CLEARING $data_dir"
# rm $data_dir/*.jpg

echo "GETTING UPDATED URL"
url=$(curl -s https://v.angelcam.com/iframe\?v\=9klzdgn2y4\&autoplay\=1 | grep 'source: ' | grep -Eo 'https://[^/"]+.*' | cut -d \' -f 1)

echo "FOUND $url"
echo "GRABBING SCREENSHOTS"

# ffmpeg -i $url -vf fps=1/10 $data_dir/bigtexan_$(date +%s)_%05d.jpg -hide_banner
while :
do
	echo "Grabbing Screenshot -> Press [CTRL+C] to stop.."
	ffmpeg -hide_banner -loglevel panic -i $url -frames:v 1 $data_dir/bigtexan_$(date +%s).jpg
  echo " -- grabbed, sleeping for 30"
  sleep 30
  done
