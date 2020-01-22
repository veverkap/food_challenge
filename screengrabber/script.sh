#!/bin/bash
data_dir="$(dirname $(dirname $(realpath $0)) )/images"
echo "DATA: $data_dir"

rm $data_dir/*.jpg

ffmpeg -i "https://e1-na8.angelcam.com/m7-na3/cameras/54700/streams/hls/playlist.m3u8?token=eyJjYW1lcmFfaWQiOiI1NDcwMCIsInRpbWUiOjE1Nzk3MjMxMTE3MDQ5MDYsInRpbWVvdXQiOjM2MDB9%2Ef01c622f5307fe0071bfae94a41c80968755ca3128b0ec6b73899f8796f5cd3b" -vf fps=1/10 $data_dir/bigtexan_%04d.jpg -hide_banner
