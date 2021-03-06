
from cvlib.object_detection import draw_bbox
from urllib.request import urlopen
import collections
import logging
import sys
# import cv2
# import cvlib as cv
import json
import os
import re
import subprocess
import time
from rectangle import Rectangle
from slacker import Slacker
from processor import Processor


root = logging.getLogger()
root.setLevel(logging.INFO)

handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.INFO)
formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
root.addHandler(handler)


def download_url(source, destination):
    logging.info("Downloading %s to %s", source, destination)
    rc = subprocess.call("wget -q -nc -O " +
                         destination + " " + source, shell=True)
    return rc


def snapshot_video(video_url):
    image_url = video_url.replace(
        videos_folder, images_folder).replace(".ts", ".jpg")
    rc = subprocess.call("ffmpeg -hide_banner -loglevel panic -i " +
                         video_url + " -vframes 1 -f image2 " + image_url, shell=True)
    return image_url


def find_segments(string):
    segments = re.findall('segment-\d*\.ts', string)
    return segments


def load_url(url):
    f = urlopen(url)
    return f.read().decode("utf-8")


def load_ts_segments(url):
    html = load_url(url)

    playlist_url = re.findall('(https?://.*\.m3u8\?token=.*)\'', html)[0]
    logging.info("found playlist_url = %s", playlist_url)

    base = "/".join(playlist_url.split("/")[:-1])
    logging.info("base = %s", base)
    values = load_url(playlist_url)
    segments = find_segments(values)
    return base, segments


def process(filename):
    Processor(filename).process()


videos_folder = "./videos/"
images_folder = "./images/"

url = "https://v.angelcam.com/iframe?v=9klzdgn2y4"

while 1:
    base, segments = load_ts_segments(url)
    for segment in segments:
        remote_url = (base + "/" + segment)
        logging.info("Loading TS Segment %s", remote_url)
        video_url = videos_folder + segment

        if download_url(remote_url, video_url) == 0:
            logging.info("Processing file")
            image_url = snapshot_video(video_url)
            process(image_url)
            try:
                os.remove(video_url)
            except:
                print("Error while deleting file ", video_url)
    logging.info("Sleeping for 30 seconds")
    time.sleep(30)
# # process("./images/segment-48659.jpg")
