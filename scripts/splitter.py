from urllib.request import urlopen
import re
import subprocess
import time


def find_segments(string):
    segments = re.findall('segment-\d*\.ts', string)
    return segments


def playlist(string):
    url = re.findall('(https?://.*\.m3u8\?token=.*)\'', string)[0]
    return url


def load_url(url):
    f = urlopen(url)
    return f.read().decode("utf-8")


url = "https://v.angelcam.com/iframe?v=9klzdgn2y4"

playlist_url = load_url(url)

playlist = playlist(playlist_url)

base = "/".join(playlist.split("/")[:-1])

values = load_url(playlist)

while 1:
    for segment in find_segments(values):
        segment_url = (base + "/" + segment)
        rc = subprocess.call("wget -nc -O ../videos/" + segment +
                             " " + segment_url, shell=True)
        print(rc)
    print("Sleeping for 30 seconds")
    time.sleep(30)
